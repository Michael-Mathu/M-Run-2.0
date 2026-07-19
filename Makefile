.PHONY: help setup-app run-app run-backend analyze test-all test-go

help:
	@echo "Mwendo Development Commands"
	@echo "  make setup-app     — Install app + packages dependencies"
	@echo "  make run-app       — Run the Flutter app"
	@echo "  make run-backend   — Start the Go backend (needs DB/Redis running)"
	@echo "  make analyze       — Run flutter analyze across app + packages"
	@echo "  make test-all      — Run app widget tests + backend Go tests"
	@echo "  make test-go       — Run backend Go tests"
	@echo ""
	@echo "Docker:"
	@echo "  docker compose up  — Start backend (PostGIS + Redis + API)"

# ---- App ----

setup-app:
	cd app && flutter pub get
	cd packages/mwendo_gps_engine && flutter pub get
	cd packages/mwendo_fit_parser && flutter pub get

run-app:
	cd app && flutter run

analyze:
	cd app && flutter analyze
	cd packages/mwendo_gps_engine && flutter analyze
	cd packages/mwendo_fit_parser && flutter analyze

# ---- Backend ----

run-backend:
	cd backend && go run ./cmd/api

test-go:
	cd backend && go test ./...

# ---- All ----

test-all: test-go
	cd app && flutter test