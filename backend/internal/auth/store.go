package auth

import (
	"context"
	"database/sql"
	"errors"
	"sync"
	"time"

	"golang.org/x/crypto/bcrypt"
)

// ErrNotFound is returned when an account does not exist.
var ErrNotFound = errors.New("account not found")

// Store abstracts account persistence so the API can run against Postgres
// in production or a simple in-memory map in local/dev without a database.
type Store interface {
	Create(ctx context.Context, email, passwordHash string) (User, error)
	GetByEmail(ctx context.Context, email string) (User, error)
}

type User struct {
	ID         string    `json:"id"`
	Email      string    `json:"email"`
	Password   string    `json:"-"`
	CreatedAt time.Time `json:"created_at"`
}

type ErrConflict struct{ Email string }

func (e ErrConflict) Error() string { return "email already registered: " + e.Email }

// IsConflict reports whether err is an ErrConflict (duplicate registration).
func IsConflict(err error) bool {
	var c ErrConflict
	return errors.As(err, &c)
}

// DBStore is the production account store backed by PostgreSQL.
type DBStore struct{ db *sql.DB }

func NewDBStore(db *sql.DB) *DBStore { return &DBStore{db: db} }

func (s *DBStore) Create(ctx context.Context, email, passwordHash string) (User, error) {
	u := User{Email: email, Password: passwordHash, CreatedAt: time.Now()}
	err := s.db.QueryRowContext(ctx, `
		INSERT INTO accounts (id, email, password_hash, created_at)
		VALUES (gen_random_uuid()::text, $1, $2, $3)
		ON CONFLICT (email) DO NOTHING
		RETURNING id`,
		email, passwordHash, u.CreatedAt,
	).Scan(&u.ID)
	if errors.Is(err, sql.ErrNoRows) {
		return User{}, ErrConflict{Email: email}
	}
	if err != nil {
		return User{}, err
	}
	return u, nil
}

func (s *DBStore) GetByEmail(ctx context.Context, email string) (User, error) {
	var u User
	err := s.db.QueryRowContext(ctx, `
		SELECT id, email, password_hash, created_at
		FROM accounts WHERE email = $1`, email,
	).Scan(&u.ID, &u.Email, &u.Password, &u.CreatedAt)
	if errors.Is(err, sql.ErrNoRows) {
		return User{}, ErrNotFound
	}
	return u, err
}

// MemoryStore is the fallback used when DATABASE_URL is not configured.
// ponytail: single global mutex; fine for dev/tests, not for concurrency at scale.
type MemoryStore struct {
	mu    sync.Mutex
	users map[string]User
}

func NewMemoryStore() *MemoryStore { return &MemoryStore{users: map[string]User{}} }

func (s *MemoryStore) Create(ctx context.Context, email, passwordHash string) (User, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if _, ok := s.users[email]; ok {
		return User{}, ErrConflict{Email: email}
	}
	u := User{
		ID:         "mem-" + email,
		Email:      email,
		Password:   passwordHash,
		CreatedAt: time.Now(),
	}
	s.users[email] = u
	return u, nil
}

func (s *MemoryStore) GetByEmail(ctx context.Context, email string) (User, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	u, ok := s.users[email]
	if !ok {
		return User{}, ErrNotFound
	}
	return u, nil
}

// HashPassword is exported so callers can reuse the cost policy.
func HashPassword(password string) (string, error) {
	b, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	return string(b), err
}
