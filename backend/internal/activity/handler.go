package activity

import (
	"encoding/json"
	"errors"
	"net/http"
	"strconv"
	"strings"

	"github.com/mwendo/backend/internal/auth"
)

var store Store

func Init(s Store) { store = s }

func Handler(w http.ResponseWriter, r *http.Request) {
	userID := auth.UserID(r)
	switch r.Method {
	case "GET":
		limit, _ := strconv.Atoi(r.URL.Query().Get("limit"))
		list, err := store.List(r.Context(), userID, limit)
		if err != nil {
			http.Error(w, "server error", http.StatusInternalServerError)
			return
		}
		writeJSON(w, list)
	case "POST":
		var in ActivityInput
		if err := json.NewDecoder(r.Body).Decode(&in); err != nil {
			http.Error(w, "invalid", http.StatusBadRequest)
			return
		}
		if in.StartedAt.IsZero() {
			http.Error(w, "started_at required", http.StatusBadRequest)
			return
		}
		a, err := store.Create(r.Context(), userID, in)
		if err != nil {
			http.Error(w, "server error", http.StatusInternalServerError)
			return
		}
		writeJSON(w, a)
	default:
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
	}
}

func DetailHandler(w http.ResponseWriter, r *http.Request) {
	userID := auth.UserID(r)
	id := strings.TrimPrefix(r.URL.Path, "/api/v1/activities/")
	if id == "" {
		http.Error(w, "missing id", http.StatusBadRequest)
		return
	}
	tol, _ := strconv.ParseFloat(r.URL.Query().Get("simplify"), 64)
	if tol <= 0 {
		tol = 1.0 // 1 metre default simplification tolerance
	}
	a, err := store.Get(r.Context(), id, userID, tol)
	if errors.Is(err, ErrNotFound) {
		http.Error(w, "not found", http.StatusNotFound)
		return
	}
	if err != nil {
		http.Error(w, "server error", http.StatusInternalServerError)
		return
	}
	writeJSON(w, a)
}

func writeJSON(w http.ResponseWriter, v interface{}) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(v)
}
