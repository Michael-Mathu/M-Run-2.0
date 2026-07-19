-- Enable PostGIS for geospatial types (geography/4326).
CREATE EXTENSION IF NOT EXISTS postgis;

-- Accounts (replaces the in-memory user map).
CREATE TABLE IF NOT EXISTS accounts (
    id            TEXT PRIMARY KEY,
    email         TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Activities. route is the full GPS trace as a geography LineString (WGS84).
CREATE TABLE IF NOT EXISTS activities (
    id                TEXT PRIMARY KEY,
    user_id           TEXT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    type              TEXT NOT NULL DEFAULT 'run',
    started_at        TIMESTAMPTZ NOT NULL,
    ended_at          TIMESTAMPTZ,
    distance_m        DOUBLE PRECISION NOT NULL DEFAULT 0,
    moving_time_ms     BIGINT NOT NULL DEFAULT 0,
    elevation_gain_m  DOUBLE PRECISION NOT NULL DEFAULT 0,
    route             GEOGRAPHY(LineString, 4326)
);
CREATE INDEX IF NOT EXISTS idx_activities_user ON activities(user_id, started_at DESC);

-- Trackpoints: per-sample GPS fixes as geography Points (WGS84).
CREATE TABLE IF NOT EXISTS trackpoints (
    id           TEXT PRIMARY KEY,
    activity_id  TEXT NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    seq          INTEGER NOT NULL,
    geom         GEOGRAPHY(Point, 4326) NOT NULL,
    elevation_m  DOUBLE PRECISION NOT NULL DEFAULT 0,
    speed_mps    DOUBLE PRECISION NOT NULL DEFAULT 0,
    ts           TIMESTAMPTZ NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_trackpoints_activity ON trackpoints(activity_id, seq);

-- Personal records derived from finished activities.
CREATE TABLE IF NOT EXISTS personal_records (
    id          TEXT PRIMARY KEY,
    user_id     TEXT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    metric      TEXT NOT NULL,           -- e.g. longest_run, fastest_5k
    value       DOUBLE PRECISION NOT NULL,
    activity_id TEXT REFERENCES activities(id) ON DELETE SET NULL,
    achieved_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (user_id, metric)
);
