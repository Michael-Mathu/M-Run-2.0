package auth

import (
	"context"
	"testing"
)

func TestMemoryStoreRegisterLoginConflict(t *testing.T) {
	s := NewMemoryStore()
	ctx := context.Background()
	if _, err := s.Create(ctx, "a@b.com", "hash"); err != nil {
		t.Fatalf("create: %v", err)
	}
	if _, err := s.Create(ctx, "a@b.com", "hash"); !IsConflict(err) {
		t.Fatalf("expected conflict, got %v", err)
	}
	if _, err := s.GetByEmail(ctx, "missing@b.com"); err != ErrNotFound {
		t.Fatalf("expected ErrNotFound, got %v", err)
	}
}
