package leaderboard

import (
	"context"
	"sort"
	"sync"
	"time"

	"github.com/redis/go-redis/v9"
)

const keyWeekly = "mwendo:leaderboard:weekly"

// Leaderboard ranks users by a score (e.g. weekly distance in metres).
// It prefers Redis (sorted set) but degrades to an in-process map when no
// Redis is configured, so the API stays runnable in local dev.
type Leaderboard struct {
	rdb *redis.Client
	mu  sync.Mutex
	mem map[string]float64
}

func New(redisURL string) *Leaderboard {
	lb := &Leaderboard{mem: map[string]float64{}}
	if redisURL != "" {
		opt, err := redis.ParseURL(redisURL)
		if err != nil {
			// ponytail: invalid URL -> run in-memory rather than crash.
			return lb
		}
		lb.rdb = redis.NewClient(opt)
	}
	return lb
}

func (lb *Leaderboard) Submit(ctx context.Context, userID string, score float64) error {
	if lb.rdb != nil {
		return lb.rdb.ZIncrBy(ctx, keyWeekly, score, userID).Err()
	}
	lb.mu.Lock()
	lb.mem[userID] += score
	lb.mu.Unlock()
	return nil
}

type Entry struct {
	UserID string  `json:"user_id"`
	Score  float64 `json:"score"`
	Rank   int     `json:"rank"`
}

func (lb *Leaderboard) Top(ctx context.Context, n int) ([]Entry, error) {
	if n <= 0 || n > 100 {
		n = 10
	}
	if lb.rdb != nil {
		res, err := lb.rdb.ZRevRangeWithScores(ctx, keyWeekly, 0, int64(n-1)).Result()
		if err != nil {
			return nil, err
		}
		out := make([]Entry, 0, len(res))
		for i, z := range res {
			out = append(out, Entry{UserID: z.Member.(string), Score: z.Score, Rank: i + 1})
		}
		return out, nil
	}
	lb.mu.Lock()
	defer lb.mu.Unlock()
	ents := make([]Entry, 0, len(lb.mem))
	for u, s := range lb.mem {
		ents = append(ents, Entry{UserID: u, Score: s})
	}
	sort.Slice(ents, func(i, j int) bool { return ents[i].Score > ents[j].Score })
	if len(ents) > n {
		ents = ents[:n]
	}
	for i := range ents {
		ents[i].Rank = i + 1
	}
	return ents, nil
}

// Expiry returns the remaining weekly window for the Redis-backed board,
// or a zero duration for the in-memory fallback.
func (lb *Leaderboard) Expiry(ctx context.Context) time.Duration {
	if lb.rdb == nil {
		return 0
	}
	d, _ := lb.rdb.TTL(ctx, keyWeekly).Result()
	return d
}
