package auth

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"errors"
	"net/http"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

// Set at startup by main.go. ponytail: refresh tokens stay in-memory; a
// real deployment would persist them (e.g. Redis) to survive restarts.
var store Store
var jwtSecret []byte
var refreshTokens = make(map[string]string)

func Init(s Store, secret []byte) {
	store = s
	jwtSecret = secret
}

type Claims struct {
	UserID string `json:"user_id"`
	jwt.RegisteredClaims
}

func newAccessToken(userID string) (string, error) {
	tok := jwt.NewWithClaims(jwt.SigningMethodHS256, Claims{
		UserID: userID,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(15 * time.Minute)),
		},
	})
	return tok.SignedString(jwtSecret)
}

func Register(w http.ResponseWriter, r *http.Request) {
	var req struct{ Email, Password string }
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "invalid", http.StatusBadRequest)
		return
	}
	if req.Email == "" || len(req.Password) < 8 {
		http.Error(w, "email and password (>=8 chars) required", http.StatusBadRequest)
		return
	}
	hash, err := HashPassword(req.Password)
	if err != nil {
		http.Error(w, "server error", http.StatusInternalServerError)
		return
	}
	if _, err := store.Create(r.Context(), req.Email, hash); err != nil {
		if errors.As(err, &ErrConflict{}) {
			http.Error(w, err.Error(), http.StatusConflict)
			return
		}
		http.Error(w, "server error", http.StatusInternalServerError)
		return
	}
	writeJSON(w, map[string]string{"status": "ok"})
}

func Login(w http.ResponseWriter, r *http.Request) {
	var req struct{ Email, Password string }
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "invalid", http.StatusBadRequest)
		return
	}

	user, err := store.GetByEmail(r.Context(), req.Email)
	if errors.Is(err, ErrNotFound) {
		http.Error(w, "not found", http.StatusUnauthorized)
		return
	}
	if err != nil {
		http.Error(w, "server error", http.StatusInternalServerError)
		return
	}
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		http.Error(w, "invalid", http.StatusUnauthorized)
		return
	}

	access, err := newAccessToken(user.ID)
	if err != nil {
		http.Error(w, "server error", http.StatusInternalServerError)
		return
	}
	refresh := randomToken()
	refreshTokens[refresh] = user.ID
	http.SetCookie(w, &http.Cookie{
		Name: "refresh_token", Value: refresh, HttpOnly: true, SameSite: http.SameSiteLaxMode,
	})
	writeJSON(w, map[string]string{"access_token": access})
}

func Refresh(w http.ResponseWriter, r *http.Request) {
	cookie, err := r.Cookie("refresh_token")
	if err != nil {
		http.Error(w, "missing", http.StatusUnauthorized)
		return
	}
	userID, ok := refreshTokens[cookie.Value]
	if !ok {
		http.Error(w, "invalid", http.StatusUnauthorized)
		return
	}
	access, err := newAccessToken(userID)
	if err != nil {
		http.Error(w, "server error", http.StatusInternalServerError)
		return
	}
	writeJSON(w, map[string]string{"access_token": access})
}

func Logout(w http.ResponseWriter, r *http.Request) {
	if cookie, _ := r.Cookie("refresh_token"); cookie != nil {
		delete(refreshTokens, cookie.Value)
	}
	http.SetCookie(w, &http.Cookie{Name: "refresh_token", Value: "", HttpOnly: true})
	writeJSON(w, map[string]string{"status": "ok"})
}

type contextKey string

const userIDKey contextKey = "userID"

func AuthMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		h := r.Header.Get("Authorization")
		if !strings.HasPrefix(h, "Bearer ") {
			http.Error(w, "unauthorized", http.StatusUnauthorized)
			return
		}
		claims := &Claims{}
		if _, err := jwt.ParseWithClaims(strings.TrimPrefix(h, "Bearer "), claims,
			func(*jwt.Token) (interface{}, error) { return jwtSecret, nil }); err != nil {
			http.Error(w, "invalid token", http.StatusUnauthorized)
			return
		}
		ctx := context.WithValue(r.Context(), userIDKey, claims.UserID)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

func UserID(r *http.Request) string {
	if v, ok := r.Context().Value(userIDKey).(string); ok {
		return v
	}
	return ""
}

func randomToken() string {
	b := make([]byte, 32)
	rand.Read(b)
	return hex.EncodeToString(b)
}

func writeJSON(w http.ResponseWriter, v interface{}) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(v)
}
