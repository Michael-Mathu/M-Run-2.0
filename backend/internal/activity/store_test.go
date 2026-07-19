package activity

import (
	"context"
	"testing"
	"time"
)

func sample() ActivityInput {
	now := time.Now()
	return ActivityInput{
		Type:      "run",
		StartedAt: now,
		DistanceM: 5000,
		MovingTimeMs: 1500000,
		Trackpoints: []Trackpoint{
			{Lat: -1.29, Lng: 36.82, Elevation: 10, SpeedMps: 3.1, Timestamp: now},
			{Lat: -1.291, Lng: 36.821, Elevation: 11, SpeedMps: 3.2, Timestamp: now.Add(time.Minute)},
		},
	}
}

func TestMemoryStoreLifecycle(t *testing.T) {
	s := NewMemoryStore()
	ctx := context.Background()
	got, err := s.Create(ctx, "user-1", sample())
	if err != nil {
		t.Fatalf("create: %v", err)
	}
	if got.ID == "" || len(got.Route) != 2 {
		t.Fatalf("unexpected stored activity: %+v", got)
	}

	list, err := s.List(ctx, "user-1", 10)
	if err != nil || len(list) != 1 {
		t.Fatalf("list: %v len=%d", err, len(list))
	}

	fetched, err := s.Get(ctx, got.ID, "user-1", 0)
	if err != nil || len(fetched.Trackpoints) != 2 {
		t.Fatalf("get: %v tp=%d", err, len(fetched.Trackpoints))
	}

	total, err := s.TotalDistance(ctx, "user-1")
	if err != nil || total != 5000 {
		t.Fatalf("total: %v got=%f", err, total)
	}
}
