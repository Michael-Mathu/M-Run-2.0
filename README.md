# Mwendo (M-Run 2.0) 🏃‍♂️💨

> **High-Precision GPS Running Tracker, Heritage-Driven Virtual Pacing Engine, and Geospatial Intelligence Platform.**

[![Mwendo CI](https://github.com/Michael-Mathu/M-Run-2.0/actions/workflows/test.yml/badge.svg)](https://github.com/Michael-Mathu/M-Run-2.0/actions/workflows/test.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.22+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Go](https://img.shields.io/badge/Go-1.22+-00ADD8?logo=go&logoColor=white)](https://golang.org)
[![PostGIS](https://img.shields.io/badge/PostGIS-16--3.4-336791?logo=postgresql&logoColor=white)](https://postgis.net)
[![Redis](https://img.shields.io/badge/Redis-7.0+-DC382D?logo=redis&logoColor=white)](https://redis.io)
[![License](https://img.shields.io/badge/License-Apache_2.0_|_MIT-blue.svg)](LICENSE-APACHE)

---

## 🌟 Overview

**Mwendo** (*Swahili for "Speed", "Motion", or "Movement"*) is an enterprise-grade, offline-first running tracking ecosystem designed to eliminate GPS telemetry drift and ghost traces while celebrating East African distance running culture.

### Key Capabilities

* 🛰️ **Deterministic Multi-Stage GPS Pipeline**: Outlier lookahead, 2D ENU Extended Kalman Filtering, and density-weighted stationary clustering.
* 🏃 **"Beat Legends" Pacing Engine**: Race in real-time against mathematical models of world-record holders (*Eliud Kipchoge, Kelvin Kiptum, Faith Kipyegon, Kenenisa Bekele, etc.*) scaled across Bronze, Silver, Gold, and G.O.A.T. tiers.
* 🛡️ **Zero-Loss Crash Recovery**: Local SQLite storage via Drift backed by native C SQLite binaries, alongside a durable session draft journal (`SessionDrafts` and `SessionPoints`).
* 🗺️ **High-Performance Vector Maps**: Local MapLibre GL dark Carto basemap with dynamic ghost overlays, interactive auto-follow camera toggles, and live pace polyline rendering.
* ☁️ **High-Throughput Geospatial Cloud API**: Go 1.22 backend featuring PostGIS geospatial linestrings, Douglas-Peucker route simplification (`ST_Simplify`), and Redis Sorted Set leaderboards with graceful memory fallbacks.
* 🌐 **Bilingual English & Swahili UI**: Full localization across curriculum, legends history, and real-time audio/haptic cues.

---

## 🏗️ Architecture

```
M-Run-2.0/
├── app/                        # Main Flutter Client Application
│   ├── lib/
│   │   ├── core/               # Gamification, l10n, theme, permissions, safety
│   │   ├── data/               # Drift SQLite database, models, repositories, GPX
│   │   ├── design_system/      # Atomic UI components, cards, banners, HUDs
│   │   ├── features/           # Feature slices: tracking, beat, learn, explore, etc.
│   │   └── widgets/            # MapLibre map wrappers, metrics tiles, overlays
│   └── test/                   # Widget and repository integration tests
├── packages/
│   ├── gps_pipeline/           # Pure Dart GPS filter, Kalman math, quality analysis
│   ├── mwendo_gps_engine/      # Federated platform plugin (Android Foreground / iOS)
│   └── mwendo_fit_parser/      # Rust FFI bridge for binary Garmin FIT file parsing
├── backend/                    # Go Cloud Service (PostGIS + Redis + JWT Auth)
│   ├── cmd/api/                # HTTP server bootstrap and routing
│   └── internal/               # Activity, Auth, DB, Config, and Leaderboard domains
├── app-rn/                     # React Native Type & Schema Parity Definitions
├── docker-compose.yml          # PostGIS 16 + Redis 7 + Go API orchestration
└── Makefile                    # Unified build, test, and execution tasks
```

For in-depth architectural details, see the [Architecture Documentation](docs/ARCHITECTURE.md).

---

## 🚀 Quick Start

### Prerequisites
* **Flutter SDK**: `^3.22.0` (Dart `^3.12.2`)
* **Go SDK**: `^1.22.0`
* **Docker & Docker Compose**
* **Rust & Cargo** (for native FIT parser FFI)

### 1. Install Dependencies
```bash
make setup-app
```

### 2. Start Backend Services (PostGIS & Redis)
```bash
docker compose up -d
```

### 3. Run the Flutter App
```bash
make run-app
```

### 4. Run Tests & Static Analysis
```bash
make analyze
make test-all
```

---

## 📚 Documentation Index

Exhaustive technical documentation is organized in the [`docs/`](docs/) directory:

| Document | Description |
| :--- | :--- |
| 📖 **[Master Technical Documentation](docs/TECHNICAL_DOCUMENTATION.md)** | Definitive source of truth covering all system domains and specifications |
| 🏛️ **[Architecture & Design](docs/ARCHITECTURE.md)** | Architectural patterns, GPS state-space Kalman filtering, data flow models |
| 🔌 **[API & Module Reference](docs/API_REFERENCE.md)** | Granular interface reference for Dart packages, Drift schema, and REST API |
| 🛠️ **[Installation & Deployment](docs/SETUP_AND_DEPLOYMENT.md)** | Step-by-step setup, Docker provisioning, and CI/CD pipelines |
| 🧭 **[Usage Guides & Tutorials](docs/USAGE_GUIDES.md)** | Practical walkthroughs for tracking, ghost racing, and quality diagnostics |
| 🎨 **[Design System](docs/DESIGN_SYSTEM.md)** | Color palettes, typography, glassmorphism tokens, and UI components |
| 🤝 **[Contribution Guidelines](docs/CONTRIBUTING.md)** | Coding standards, linting rules, testing protocol, and Git lifecycle |

---

## ⚖️ License

Mwendo is dual-licensed under the [Apache License 2.0](LICENSE-APACHE) and the [MIT License](LICENSE-MIT).
