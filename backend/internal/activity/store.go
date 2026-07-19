package activity

import (
	"context"
	"crypto/rand"
	"database/sql"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"sync"
	"time"
)

type Store interface {
	Create(ctx context.Context, userID string, in ActivityInput) (Activity, error)
	List(ctx context.Context, userID string, limit int) ([]Activity, error)
	Get(ctx context.Context, id, userID string, simplifyTol float64) (Activity, error)
	TotalDistance(ctx context.Context, userID string) (float64, error)
}

// ActivityInput is the inbound payload for creating an activity.
type ActivityInput struct {
	Type           string       `json:"type"`
	StartedAt      time.Time    `json:"started_at"`
	EndedAt        *time.Time   `json:"ended_at,omitempty"`
	DistanceM      float64      `json:"distance_m"`
	MovingTimeMs   int64        `json:"moving_time_ms"`
	ElevationGainM float64      `json:"elevation_gain_m"`
	Trackpoints    []Trackpoint `json:"trackpoints"`
}

type Activity struct {
	ID             string       `json:"id"`
	UserID         string       `json:"user_id"`
	Type           string       `json:"type"`
	StartedAt      time.Time    `json:"started_at"`
	EndedAt        *time.Time   `json:"ended_at,omitempty"`
	DistanceM      float64      `json:"distance_m"`
	MovingTimeMs   int64        `json:"moving_time_ms"`
	ElevationGainM float64      `json:"elevation_gain_m"`
	Route          [][2]float64 `json:"route,omitempty"` // [lng, lat], simplified
	Trackpoints    []Trackpoint `json:"trackpoints,omitempty"`
}

type Trackpoint struct {
	Lat       float64   `json:"lat"`
	Lng       float64   `json:"lng"`
	Elevation float64   `json:"elevation"`
	Timestamp time.Time `json:"timestamp"`
	SpeedMps  float64   `json:"speed_mps"`
}

func newID() string {
	b := make([]byte, 16)
	rand.Read(b)
	return hex.EncodeToString(b)
}

// lineStringWKT builds a WGS84 LineString WKT from lng/lat points.
func lineStringWKT(pts []Trackpoint) string {
	parts := make([]string, 0, len(pts))
	for _, p := range pts {
		parts = append(parts, fmt.Sprintf("%.8f %.8f", p.Lng, p.Lat))
	}
	return "LINESTRING(" + strings.Join(parts, ",") + ")"
}

// parseLineStringGeoJSON extracts [lng,lat] coords from ST_AsGeoJSON output.
func parseLineStringGeoJSON(geojsonText string) ([][2]float64, error) {
	if geojsonText == "" {
		return nil, nil
	}
	var g struct {
		Coordinates [][2]float64 `json:"coordinates"`
	}
	if err := json.Unmarshal([]byte(geojsonText), &g); err != nil {
		return nil, err
	}
	return g.Coordinates, nil
}

// DBStore is the production activity store backed by PostgreSQL + PostGIS.
type DBStore struct{ db *sql.DB }

func NewDBStore(db *sql.DB) *DBStore { return &DBStore{db: db} }

func (s *DBStore) Create(ctx context.Context, userID string, in ActivityInput) (Activity, error) {
	typ := in.Type
	if typ == "" {
		typ = "run"
	}
	id := newID()

	var routeVal interface{}
	if len(in.Trackpoints) >= 2 {
		routeVal = lineStringWKT(in.Trackpoints)
	}

	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return Activity{}, err
	}
	defer tx.Rollback()

	if _, err := tx.ExecContext(ctx, `
		INSERT INTO activities (id, user_id, type, started_at, ended_at, distance_m, moving_time_ms, elevation_gain_m, route)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,
			CASE WHEN $9::text IS NOT NULL THEN ST_GeomFromText($9, 4326)::geography ELSE NULL END)`,
		id, userID, typ, in.StartedAt, in.EndedAt, in.DistanceM, in.MovingTimeMs, in.ElevationGainM, routeVal); err != nil {
		return Activity{}, err
	}

	if routeVal != nil {
		stmt, err := tx.PrepareContext(ctx, `
			INSERT INTO trackpoints (id, activity_id, seq, geom, elevation_m, speed_mps, ts)
			VALUES ($1,$2,$3,ST_MakePoint($4,$5)::geography,$6,$7,$8)`)
		if err != nil {
			return Activity{}, err
		}
		for i, p := range in.Trackpoints {
			if _, err := stmt.ExecContext(ctx, newID(), id, i, p.Lng, p.Lat, p.Elevation, p.SpeedMps, p.Timestamp); err != nil {
				stmt.Close()
				return Activity{}, err
			}
		}
		stmt.Close()
	}

	// Maintain a "longest_run" personal record for this user.
	if _, err := tx.ExecContext(ctx, `
		INSERT INTO personal_records (id, user_id, metric, value, activity_id)
		VALUES (gen_random_uuid()::text, $1, 'longest_run', $2, $3)
		ON CONFLICT (user_id, metric) DO UPDATE
		  SET value = GREATEST(personal_records.value, EXCLUDED.value),
		      activity_id = CASE WHEN EXCLUDED.value > personal_records.value THEN EXCLUDED.activity_id ELSE personal_records.activity_id END`,
		userID, in.DistanceM, id); err != nil {
		return Activity{}, err
	}

	if err := tx.Commit(); err != nil {
		return Activity{}, err
	}
	return s.Get(ctx, id, userID, 0)
}

func (s *DBStore) List(ctx context.Context, userID string, limit int) ([]Activity, error) {
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	rows, err := s.db.QueryContext(ctx, `
		SELECT id, type, started_at, ended_at, distance_m, moving_time_ms, elevation_gain_m
		FROM activities WHERE user_id = $1 ORDER BY started_at DESC LIMIT $2`, userID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := []Activity{}
	for rows.Next() {
		var a Activity
		if err := rows.Scan(&a.ID, &a.Type, &a.StartedAt, &a.EndedAt, &a.DistanceM, &a.MovingTimeMs, &a.ElevationGainM); err != nil {
			return nil, err
		}
		out = append(out, a)
	}
	return out, rows.Err()
}

func (s *DBStore) Get(ctx context.Context, id, userID string, simplifyTol float64) (Activity, error) {
	var a Activity
	var routeJSON string
	err := s.db.QueryRowContext(ctx, `
		SELECT id, user_id, type, started_at, ended_at, distance_m, moving_time_ms, elevation_gain_m,
		       COALESCE(ST_AsGeoJSON(ST_Simplify(route::geometry, $3)), '')
		FROM activities WHERE id = $1 AND user_id = $2`, id, userID, simplifyTol).
		Scan(&a.ID, &a.UserID, &a.Type, &a.StartedAt, &a.EndedAt, &a.DistanceM, &a.MovingTimeMs, &a.ElevationGainM, &routeJSON)
	if errors.Is(err, sql.ErrNoRows) {
		return Activity{}, ErrNotFound
	}
	if err != nil {
		return Activity{}, err
	}
	a.Route, _ = parseLineStringGeoJSON(routeJSON)

	tpRows, err := s.db.QueryContext(ctx, `
		SELECT ST_Y(geom::geometry), ST_X(geom::geometry), elevation_m, speed_mps, ts
		FROM trackpoints WHERE activity_id = $1 ORDER BY seq`, id)
	if err != nil {
		return a, err
	}
	defer tpRows.Close()
	for tpRows.Next() {
		var tp Trackpoint
		if err := tpRows.Scan(&tp.Lat, &tp.Lng, &tp.Elevation, &tp.SpeedMps, &tp.Timestamp); err != nil {
			return a, err
		}
		a.Trackpoints = append(a.Trackpoints, tp)
	}
	return a, tpRows.Err()
}

func (s *DBStore) TotalDistance(ctx context.Context, userID string) (float64, error) {
	var total sql.NullFloat64
	err := s.db.QueryRowContext(ctx,
		"SELECT COALESCE(SUM(distance_m),0) FROM activities WHERE user_id = $1", userID).Scan(&total)
	return total.Float64, err
}

// MemoryStore is the in-memory fallback used when DATABASE_URL is unset.
// ponytail: stores everything in maps; returns the full (unsimplified) route
// because track simplification is a PostGIS feature. Not for production use.
type MemoryStore struct {
	mu         sync.Mutex
	activities map[string]Activity
	order      []string
}

func NewMemoryStore() *MemoryStore { return &MemoryStore{activities: map[string]Activity{}} }

func (s *MemoryStore) Create(ctx context.Context, userID string, in ActivityInput) (Activity, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	typ := in.Type
	if typ == "" {
		typ = "run"
	}
	a := Activity{
		ID:             newID(),
		UserID:         userID,
		Type:           typ,
		StartedAt:      in.StartedAt,
		EndedAt:        in.EndedAt,
		DistanceM:      in.DistanceM,
		MovingTimeMs:   in.MovingTimeMs,
		ElevationGainM: in.ElevationGainM,
		Trackpoints:    in.Trackpoints,
	}
	for _, p := range in.Trackpoints {
		a.Route = append(a.Route, [2]float64{p.Lng, p.Lat})
	}
	s.activities[a.ID] = a
	s.order = append(s.order, a.ID)
	return a, nil
}

func (s *MemoryStore) List(ctx context.Context, userID string, limit int) ([]Activity, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	out := []Activity{}
	for i := len(s.order) - 1; i >= 0 && len(out) < limit; i-- {
		if a := s.activities[s.order[i]]; a.UserID == userID {
			out = append(out, a)
		}
	}
	return out, nil
}

func (s *MemoryStore) Get(ctx context.Context, id, userID string, _ float64) (Activity, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	a, ok := s.activities[id]
	if !ok || a.UserID != userID {
		return Activity{}, ErrNotFound
	}
	return a, nil
}

func (s *MemoryStore) TotalDistance(ctx context.Context, userID string) (float64, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	var t float64
	for _, a := range s.activities {
		if a.UserID == userID {
			t += a.DistanceM
		}
	}
	return t, nil
}

var ErrNotFound = errors.New("activity not found")
