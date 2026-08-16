# Mwendo Installation, Setup & Deployment Guide

---

## 1. Prerequisites & Version Requirements

| Dependency | Minimum Version | Verified Version | Purpose |
| :--- | :--- | :--- | :--- |
| **Flutter SDK** | `3.22.0` | `3.24.0` (Stable) | Mobile application runtime |
| **Dart SDK** | `3.12.2` | `3.12.2` | Core language framework |
| **Go SDK** | `1.22.0` | `1.22.5` | Backend microservice runtime |
| **Rust / Cargo** | `1.75.0` | `1.80.0` | Native binary FIT parser FFI |
| **Docker Engine** | `24.0.0` | `27.0.0` | Container orchestration |
| **Docker Compose** | `2.20.0` | `2.28.0` | Multi-container setup |
| **PostgreSQL / PostGIS**| `16-3.4` | `postgis/postgis:16-3.4`| Spatial geospatial database |
| **Redis** | `7.0` | `redis:7-alpine` | In-memory leaderboard caching |
| **Android NDK** | `26.1.10909125`| `26.x` | Rust Android ABI compiling |

---

## 2. Step-by-Step Local Setup

### 2.1 Clone Repository
```bash
git clone https://github.com/Michael-Mathu/M-Run-2.0.git
cd M-Run-2.0
```

### 2.2 Install Dependencies across Submodules
Execute the top-level make target to install dependencies across the app and all internal packages:
```bash
make setup-app
```

### 2.3 Compile Rust FFI Dynamic Library
For host execution and unit tests:
```bash
cd packages/mwendo_fit_parser/rust
cargo build --release
```

For Android NDK multi-ABI packaging:
```bash
# Requires cargo-ndk: cargo install cargo-ndk
cargo ndk -t arm64-v8a -t armeabi-v7a -t x86_64 -o ../../../app/android/app/src/main/jniLibs build --release
```

### 2.4 Run Drift Database Code Generation
```bash
cd app
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2.5 Start PostGIS & Redis via Docker
```bash
docker compose up -d
```
Verify container health:
```bash
docker compose ps
```
The database executes schema migrations automatically from `backend/internal/db/migrations/0001_init.sql`.

---

## 3. Running the System

### 3.1 Run the Flutter Mobile Application
```bash
cd app

# Default configuration (defaults to http://10.0.2.2:8080 on Android emulator)
flutter run

# Custom backend API endpoint override:
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```

### 3.2 Run the Go Backend Standalone
```bash
cd backend
export PORT=8080
export DATABASE_URL="postgres://mwendo:mwendo@localhost:5432/mwendo?sslmode=disable"
export REDIS_URL="redis://localhost:6379/0"
export JWT_SECRET="production-secure-32-byte-secret-key"
export CORS_ORIGIN="*"
go run ./cmd/api
```

---

## 4. Build & Compilation Pipelines

### 4.1 Android Production APK / App Bundle
```bash
cd app
# Release APK
flutter build apk --release --split-per-abi

# Google Play Android App Bundle (AAB)
flutter build appbundle --release
```

### 4.2 iOS Production Archive
```bash
cd app
flutter build ipa --release
```

### 4.3 Containerized Multi-Stage Docker Build
```bash
cd backend
docker build -t mwendo-api:latest .
```

---

## 5. CI/CD Workflows

### 5.1 Continuous Integration (`.github/workflows/test.yml`)
* **Flutter Test Job**: Pulls Flutter `3.x`, downloads dependencies, and executes `flutter test` across all unit/widget tests.
* **Go Test Job**: Pulls Go `1.22`, executes `go test ./...` with race detection.

### 5.2 Release Packaging (`.github/workflows/release.yml`)
* Triggered automatically on git tags matching `v*`.
* Compiles debug/release APK artifacts using Zulu OpenJDK 21.
* Automatically attaches generated `.apk` binaries to GitHub Releases.
