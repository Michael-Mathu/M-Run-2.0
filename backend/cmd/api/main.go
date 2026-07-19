package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/mwendo/backend/internal/activity"
	"github.com/mwendo/backend/internal/auth"
	"github.com/mwendo/backend/internal/config"
	"github.com/mwendo/backend/internal/db"
	"github.com/mwendo/backend/internal/leaderboard"
)

func main() {
	cfg := config.Load()
	log.Fatal(http.ListenAndServe(":"+cfg.Port, buildHandler(cfg)))
}

func buildHandler(cfg config.Config) http.Handler {
	var (
		authStore auth.Store
		actStore  activity.Store
		usingDB   bool
	)
	if cfg.DatabaseURL != "" {
		conn, err := db.Open(cfg.DatabaseURL)
		if err != nil {
			log.Fatalf("database: %v", err)
		}
		if err := db.Migrate(conn); err != nil {
			log.Fatalf("migrate: %v", err)
		}
		authStore = auth.NewDBStore(conn)
		actStore = activity.NewDBStore(conn)
		usingDB = true
	} else {
		log.Println("DATABASE_URL not set: using in-memory stores (data is not persisted)")
		authStore = auth.NewMemoryStore()
		actStore = activity.NewMemoryStore()
	}

	board := leaderboard.New(cfg.RedisURL)
	if cfg.RedisURL == "" {
		log.Println("REDIS_URL not set: leaderboard runs in-memory")
	}

	auth.Init(authStore, cfg.JWTSecret)
	activity.Init(actStore)
	leaderboard.Init(board, actStore)

	mux := http.NewServeMux()
	mux.HandleFunc("/api/v1/health", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, `{"status":"ok","database":%t,"version":"1.0.0"}`, usingDB)
	})
	mux.HandleFunc("/api/v1/auth/register", auth.Register)
	mux.HandleFunc("/api/v1/auth/login", auth.Login)
	mux.HandleFunc("/api/v1/auth/refresh", auth.Refresh)
	mux.HandleFunc("/api/v1/auth/logout", auth.Logout)

	mux.Handle("/api/v1/activities", auth.AuthMiddleware(http.HandlerFunc(activity.Handler)))
	mux.Handle("/api/v1/activities/", auth.AuthMiddleware(http.HandlerFunc(activity.DetailHandler)))
	mux.Handle("/api/v1/leaderboard", http.HandlerFunc(leaderboard.TopHandler))
	mux.Handle("/api/v1/leaderboard/submit", auth.AuthMiddleware(http.HandlerFunc(leaderboard.SubmitHandler)))

	// B3: CORS so the Flutter web build can call the API from the browser.
	handler := corsMiddleware(mux)
	return handler
}

// corsMiddleware adds permissive CORS headers and handles preflight requests,
// making the API usable from the web client as well as mobile.
func corsMiddleware(next http.Handler) http.Handler {
	allowed := envOr("CORS_ORIGIN", "*")
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", allowed)
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		w.Header().Set("Access-Control-Allow-Credentials", "true")
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}
		next.ServeHTTP(w, r)
	})
}

func envOr(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}
