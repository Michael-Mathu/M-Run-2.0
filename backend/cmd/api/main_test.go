package main

import (
	"bytes"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/mwendo/backend/internal/config"
)

func do(t *testing.T, h http.Handler, method, path, token string, body any) *http.Response {
	t.Helper()
	var rdr io.Reader
	if body != nil {
		b, _ := json.Marshal(body)
		rdr = bytes.NewReader(b)
	}
	req := httptest.NewRequest(method, path, rdr)
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)
	return rec.Result()
}

func TestAPIFlowInMemory(t *testing.T) {
	h := buildHandler(config.Config{JWTSecret: []byte("test-secret")})

	if res := do(t, h, "GET", "/api/v1/health", "", nil); res.StatusCode != 200 {
		t.Fatalf("health: %d", res.StatusCode)
	}

	if res := do(t, h, "POST", "/api/v1/auth/register", "", map[string]string{"email": "u@e.com", "password": "password1"}); res.StatusCode != 200 {
		b, _ := io.ReadAll(res.Body)
		t.Fatalf("register: %d %s", res.StatusCode, b)
	}

	login := do(t, h, "POST", "/api/v1/auth/login", "", map[string]string{"email": "u@e.com", "password": "password1"})
	if login.StatusCode != 200 {
		t.Fatalf("login: %d", login.StatusCode)
	}
	var loginRes struct{ AccessToken string `json:"access_token"` }
	json.NewDecoder(login.Body).Decode(&loginRes)
	if loginRes.AccessToken == "" {
		t.Fatal("no access token")
	}

	// Create an activity.
	create := do(t, h, "POST", "/api/v1/activities", loginRes.AccessToken, map[string]any{
		"type":        "run",
		"started_at":  "2026-07-08T06:00:00Z",
		"distance_m":  5000,
		"moving_time_ms": 1500000,
		"trackpoints": []map[string]any{
			{"lat": -1.29, "lng": 36.82, "elevation": 10, "speed_mps": 3.1, "timestamp": "2026-07-08T06:00:00Z"},
			{"lat": -1.291, "lng": 36.821, "elevation": 11, "speed_mps": 3.2, "timestamp": "2026-07-08T06:01:00Z"},
		},
	})
	if create.StatusCode != 200 {
		b, _ := io.ReadAll(create.Body)
		t.Fatalf("create activity: %d %s", create.StatusCode, b)
	}
	var act struct {
		ID    string `json:"id"`
		Route [][]float64 `json:"route"`
	}
	json.NewDecoder(create.Body).Decode(&act)
	if act.ID == "" || len(act.Route) != 2 {
		t.Fatalf("activity not stored: %+v", act)
	}

	// Fetch detail (auth required).
	detail := do(t, h, "GET", "/api/v1/activities/"+act.ID+"?simplify=1", loginRes.AccessToken, nil)
	if detail.StatusCode != 200 {
		t.Fatalf("detail: %d", detail.StatusCode)
	}

	// Unauthorized request must be rejected.
	if res := do(t, h, "GET", "/api/v1/activities", "", nil); res.StatusCode != 401 {
		t.Fatalf("expected 401, got %d", res.StatusCode)
	}

	// Leaderboard submit + top.
	if res := do(t, h, "POST", "/api/v1/leaderboard/submit", loginRes.AccessToken, nil); res.StatusCode != 200 {
		t.Fatalf("leaderboard submit: %d", res.StatusCode)
	}
	top := do(t, h, "GET", "/api/v1/leaderboard?limit=5", "", nil)
	if top.StatusCode != 200 {
		t.Fatalf("leaderboard top: %d", top.StatusCode)
	}
	var topRes struct {
		Entries []struct {
			UserID string  `json:"user_id"`
			Score  float64 `json:"score"`
			Rank   int     `json:"rank"`
		} `json:"entries"`
	}
	json.NewDecoder(top.Body).Decode(&topRes)
	if len(topRes.Entries) != 1 || topRes.Entries[0].Score != 5000 {
		t.Fatalf("leaderboard wrong: %+v", topRes.Entries)
	}
}
