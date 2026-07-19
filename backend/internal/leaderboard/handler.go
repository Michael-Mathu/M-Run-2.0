package leaderboard

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/mwendo/backend/internal/auth"
	"github.com/mwendo/backend/internal/activity"
)

var board *Leaderboard
var actStore activity.Store

func Init(b *Leaderboard, s activity.Store) {
	board = b
	actStore = s
}

// TopHandler returns the top N weekly leaderboard entries.
func TopHandler(w http.ResponseWriter, r *http.Request) {
	n, _ := strconv.Atoi(r.URL.Query().Get("limit"))
	entries, err := board.Top(r.Context(), n)
	if err != nil {
		http.Error(w, "leaderboard unavailable", http.StatusServiceUnavailable)
		return
	}
	writeJSON(w, map[string]interface{}{"entries": entries})
}

// SubmitHandler adds the authenticated user's total distance to the board.
func SubmitHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	userID := auth.UserID(r)
	total, err := actStore.TotalDistance(r.Context(), userID)
	if err != nil {
		http.Error(w, "server error", http.StatusInternalServerError)
		return
	}
	if err := board.Submit(r.Context(), userID, total); err != nil {
		http.Error(w, "leaderboard unavailable", http.StatusServiceUnavailable)
		return
	}
	writeJSON(w, map[string]float64{"submitted_m": total})
}

func writeJSON(w http.ResponseWriter, v interface{}) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(v)
}
