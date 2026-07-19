# Project Mwendo — Final Canonical Blueprint
## The Open-Source Running Platform Built in Kenya, for the World
### A tracker, teacher, and challenge companion — no AI coach, just knowledge, heritage, and community.

> **Document status:** This is the single source of truth. It supersedes both research documents and all prior drafts. All contradictions have been resolved herein.

---

## 1. Vision

Build the world's most comprehensive open-source running tracker, educator, and challenge platform — born in Kenya, inspired by East African excellence, and trusted by runners everywhere. It measures every step, teaches the art and science of running, and connects users through challenges and the stories of the sport's greatest legends. No AI coach; just your own effort, knowledge, and community.

---

## 2. Mission

Mwendo helps people:

- **Discover** running through accessible, self-paced education
- **Build** healthy habits with motivating challenges and gamification
- **Improve** performance by tracking every metric and personal record
- **Learn** the science of running — heart rate, technique, training principles
- **Celebrate** East African running heritage through interactive history, legends, and culture
- **Support** schools and coaches with practical, free tools
- **Inspire** the next generation by connecting them to the spirit of champions

---

## 3. Core Design Principles

| Principle | Detail |
|---|---|
| Open source | All code, maps, and educational content under open licences |
| Privacy-first | Data stays on device; cloud sync is opt-in and encrypted |
| Offline-first | Full recording, learning, and challenge functionality without internet |
| Cross-platform | Android & iOS, with a clear path to desktop and web |
| Built for everyone | Beginners, professionals, children, adults, seniors |
| Accessible | Screen-reader support, high-contrast maps, multilingual (Swahili & English at launch) |
| Optimised for Kenya & East Africa | Tested on low-end devices, intermittent connectivity, and local running culture |
| Scalable for global adoption | Architecture designed to grow beyond East Africa |
| Modular | Clean separation of tracker, education, challenges, and school tools |
| No black-box AI | Knowledge and motivation come from human-curated content, not opaque algorithms |

---

## 4. Target Audience

### Individuals
- Beginners taking their first walk-run
- Recreational runners aiming for 5K, 10K, half or full marathon
- Competitive athletes chasing personal bests
- Children (parental-managed accounts)
- Seniors looking for gentle activity and health education

### Organisations
- Schools (PE programmes, house competitions)
- Universities and colleges
- Running clubs and community groups
- Professional coaches and athletics trainers
- Race organisers and national athletics federations

---

## 5. Nine Pillars — Summary

| # | Pillar | Description |
|---|---|---|
| 1 | Professional Activity Engine | GPS tracking, maps, analytics, safety. The foundation. |
| 2 | Running Education & Heritage | In-app academy: technique, science, health, and the full history & culture of Kenyan/East African running. |
| 3 | East African Legends | Interactive profiles: biographies, records, memorable races, quotes. |
| 4 | Beat the Legends | Ghost-runner challenges against legendary performances. |
| 5 | Running Challenges | Large library of individual and community challenges. |
| 6 | Gamification | XP, levels, badges, streaks, leaderboards. |
| 7 | Schools & Coach Tools | Class management, attendance, competitions, coach dashboards. |
| 8 | Safety | Emergency SOS, live location sharing, incident detection. |
| 9 | Wearable Integration | Data ingestion from other platforms via Open Wearables; later direct watch companions. |

**Removed entirely:** ~~AI Coach~~, ~~AI Storytelling~~ — replaced by template-based milestone stories that run entirely offline.

---

## 6. Detailed Pillar Specifications

### Pillar 1 — Professional Activity Engine

The bedrock. A robust, privacy-respecting run tracker that rivals any commercial app.

#### GPS Tracking (Adaptive Background Engine)

The GPS engine is a **native Flutter plugin** (Kotlin on Android, Swift on iOS), architecturally based on the Apache-2.0-licensed **OpenTracks** project. RunnerUp (GPLv3) techniques are treated as design inspiration only — clean-room reimplementation of non-copylightable engineering concepts, no GPL code copied or adapted.

**Adaptive Sampling via Speed-Based Hysteresis** (from Dev Research — the most implementation-ready spec):

| Physical State | Speed Threshold | Update Interval | Hysteresis Samples |
|---|---|---|---|
| Idle | < 0.8 m/s | 45 seconds | Downgrade: 15–30 consecutive |
| Walking / Jogging | 0.8 – 5.0 m/s | 12 seconds | Upgrade: 2–5 consecutive |
| Running / Driving | > 5.0 m/s | 5 seconds | Upgrade: 2–5 consecutive |

Key design decisions:
- **Asymmetric confirmation:** upgrading (detecting movement onset) requires fewer confirmations than downgrading (detecting a stop) — prevents recording gaps at traffic lights or shoe-tying pauses.
- **Big-jump override:** dynamic distance thresholds filter GPS-to-WiFi/cellular multipath jumps while allowing legitimate rapid movement.
- **Watchdog timer:** if the primary location stream goes silent beyond a calculated threshold, the watchdog forces a direct, high-accuracy positional pull to bypass OS-level throttling (Doze mode, App Standby).
- **Crash recovery:** telemetry stream caches coordinates to local SQLite in real-time; on next launch, interrupted sessions are detected and seamlessly reconstructed (route, distance, elapsed time to the exact millisecond of failure).
- **Serial operation queues:** lock start/stop commands to prevent race conditions during rapid pause/resume cycles.

**Background execution:**
- Android: persistent foreground service with notification
- iOS: Core Location background modes

**Battery profiles:** Standard, Power Saver, Ultra-Saver

**Route smoothing:** Kalman filter for real-time; Ramer-Douglas-Peucker for post-processing.

#### Live Activity Map

- Real-time breadcrumb trail, current location marker, direction indicator
- Distance markers every 1 km (configurable)
- Auto-centre / manual pan & zoom
- Offline vector maps (OpenStreetMap via MapLibre GL + MBTiles)
- Satellite and street views

#### Live Dashboard

Displays during every run:
> Distance · Current pace · Average pace · Speed · Elapsed time · Moving time · Elevation gain/loss · Cadence · Heart rate · Calories · Lap splits (manual & automatic)

#### Smart Recording

- Auto-pause / auto-resume (configurable thresholds)
- Voice announcements (pre-recorded) for km splits, new PRs, challenge milestones
- GPS quality indicator, low-battery alerts
- Auto-save incomplete activities on termination

#### Route Management

- Save, favourite, and revisit routes
- Route history and personal heat-map
- GPX / FIT / TCX import and export (FIT parsing via MIT-licensed `fitparser` Rust crate — confirmed free of Garmin SDK licensing conflicts)

#### Performance Analytics

- Personal records: fastest 1K, 1 mile, 5K, 10K, half marathon, marathon; longest run; most elevation
- Pace, elevation, and heart-rate graphs (per run, week, month, year)
- Weekly, monthly, and annual summaries with trend indicators

---

### Pillar 2 — Running Education & Kenyan Heritage Academy

A complete, self-paced academy blending sports science with East Africa's unparalleled running story. All content is human-curated; coaches may reference it when manually writing workout assignments.

#### Running Science & Technique
- Heart rate zones, VO₂ max, lactate threshold, energy systems
- Posture, cadence, foot strike, breathing
- Training types: long run, tempo, intervals, hills, recovery
- Health: warm-up, stretching, strength for runners, injury awareness

#### Special Programmes
- Children & youth athletics
- Women in running
- Older adult fitness

#### Kenyan & East African Running Legacy
- **History:** pre-colonial running traditions → global dominance (Kipchoge Keino's 1968/72 Olympics through modern era)
- **Altitude training:** physiological effects of training at 2,400 m in the Rift Valley — erythropoiesis, red-dirt terrain, tendon stiffness
- **Famous training camps:** Iten, Kaptagat, Ngong, Eldoret — the "Valley of Champions"
- **The Thursday Fartlek:** structured 15 km group run, 3/1, 2/1, 1/1 intervals, lactate clearance philosophy, effort-over-pace mentality
- **School athletics culture:** KSSSA, National Trials, grassroots pathway
- **Socioeconomics:** Athletics Kenya, Standard Chartered Nairobi Marathon, BingwaFest, athlete entrepreneurship in Eldoret
- **Traditional training philosophies:** communal mentorship, simple living, ugali-and-tea nutrition, the role of community
- **Great running regions:** Rift Valley, Nandi County, Arusha

#### Delivery
- Rich articles, photographs, audio interviews, short videos
- Interactive quizzes and "knowledge badges"
- All content downloadable for offline use
- Swahili and English at launch; framework ready for more languages

---

### Pillar 3 — East African Legends

A growing, curated library of interactive profiles (30 seeded across Kenya, Ethiopia, Uganda and
beyond). Each legend's page contains:

- Biography, career timeline, and a personal-bests grid
- Major championships and memorable races (notable-races cards)
- Training philosophy, with a link to the related education course
- Rivalries (tappable chips) and related legends (cross-linked carousel)
- Categorized quotes (Training / Racing / Life / Legacy) and a fun-fact card
- "Challenge Me" button → suggests a Beat the Legends challenge

The legends list is searchable and filterable by country, discipline, and era. A "Legend of the
Day / Week" card surfaces a rotating legend (and a fun fact) on the home screen, and a "How You
Compare" panel matches the user's logged PBs against the legend's records.

Users can "follow" a legend; community contributors may submit new legends for review.

#### Foundational Content Data (from Content Research)

**Male legends (initial dataset):**

| Athlete | Key Distance | Record Time | Venue & Year | Notes |
|---|---|---|---|---|
| Eliud Kipchoge | Marathon | 2:01:09 | Berlin 2022 | Positive split; 59:51 first half |
| Eliud Kipchoge | Marathon | 2:01:39 | Berlin 2018 | Negative split; 1:01:06 first half |
| Eliud Kipchoge | Marathon | 1:59:40 | Vienna 2019 | Unofficial exhibition; optimised pacing |
| Kelvin Kiptum | Marathon | 2:00:35 | Chicago 2023 | Aggressive negative split |
| Sabastian Sawe | Marathon | 1:59:30 | London 2026 | ⚠️ Verify against World Athletics ratification |
| Haile Gebrselassie | Marathon | 2:03:59 | Berlin 2008 | First sub-2:04; 1:01:57 second half |
| Paul Tergat | Marathon | 2:04:55 | Berlin 2003 | First sub-2:05 |
| Paul Tergat | Half Marathon | 59:17 | — | |
| Paul Tergat | 10,000m | 26:27.85 | — | |
| Kipchoge Keino | 1500m | Gold | Mexico City 1968 | Initiated East African Olympic dominance |

**Female legends (initial dataset):**

| Athlete | Key Distance | Record Time | Venue & Year |
|---|---|---|---|
| Faith Kipyegon | 1500m | 3:48.68 | Eugene 2025 |
| Faith Kipyegon | 5000m | 14:05.20 | Paris 2023 |
| Beatrice Chebet | 5000m | 13:58.06 | Eugene 2025 |
| Brigid Kosgei | Marathon | 2:14:04 | Chicago 2019 |
| Ruth Chepngetich | Marathon | 2:09:56 | Chicago 2024 |
| Tigist Assefa | Marathon | 2:11:53 | Berlin 2023 |
| Tegla Loroupe | Marathon | 2:20:43 | Berlin 1999 |

---

### Pillar 4 — Beat the Legends

- Ghost runner on the map during a run (e.g., Kipchoge's marathon splits, Faith Kipyegon's 1500m)
- Real-time feedback: "You're 10 metres ahead of 2003 Bekele at this point"
- Difficulty tiers so any runner can take on a legend: **Bronze** (125% of record time),
  **Silver** (110%), **Gold** (102%), and **G.O.A.T.** (the actual world record, 100%). Each
  ghost pace ships with all four tiers; the splits, header, and race target rescale live.
- Rewards: exclusive badges, medals, and titles per tier beaten
- Maps directly to **Octalysis Core Drive 1: Epic Meaning and Calling** (from Content Research)

---

### Pillar 5 — Running Challenges

| Category | Examples |
|---|---|
| Starter | First Run, First 5K, 7-Day Streak |
| Milestones | 10K, Half Marathon, Marathon |
| Performance | Sub-25 5K, Sub-50 10K (based on PR progression) |
| Fun & seasonal | Sunrise Challenge, Hill Repeat Challenge, Rift Valley Altitude, Rainy Season Streak |
| School & Club | House competitions, inter-school challenges |
| Community-voted | Regular polls in the app/forum |

All challenges reward XP, badges, and unlockable medals.

---

### Pillar 6 — Gamification

Designed using the **Octalysis Framework** (8 core drives) and **Hooked Model** (Trigger → Action → Variable Reward → Investment), as detailed in both research documents.

| Element | Detail |
|---|---|
| XP system | Earned from distance, challenges, lessons, PRs, streaks |
| Levels | 1–100 (exponential growth); unlocks profile customisation |
| Badges | Hundreds, including hidden quirky ones |
| Streaks | Daily, weekly, monthly run streaks; "Knowledge streak" for learning |
| Leaderboards | Opt-in; filtered by club, school, region, country, global |
| Titles | Earnable monikers: "Mountain Goat", "Historian", "5K Master" |

**White Hat / Black Hat balance:** Epic Meaning (CD1), Accomplishment (CD2), Empowerment (CD3), Ownership (CD4) are the primary engagement drivers. Scarcity (CD6), Unpredictability (CD7), and Loss Avoidance (CD8) are used sparingly — overuse causes burnout. Streaks (CD8) are protected by a "streak freeze" mechanic to prevent negative psychology.

**Hooked Model integration:** Push notification trigger → single-tap run start (low-friction action) → variable XP / surprise badge (reward) → profile customisation / streak investment.

---

### Pillar 7 — Schools & Coach Portal

**Schools Mode:**
- Teacher/student roles, join codes
- Digital attendance for PE sessions
- Assign challenges ("Run 3 km this week")
- House-based scoring, inter-class competitions
- Parental consent for under-13s
- Certificates for milestones and learning

**Coach Portal (web-based):**
- Athlete management: group runners, view logs, track attendance
- Manual workout assignment: text descriptions, distance/pace targets
- Progress monitoring: graphs and tables of key metrics
- Feedback: comments and voice notes on completed activities
- Team management: multiple squads, sharing settings

---

### Pillar 8 — Safety

Works offline.

- **Emergency SOS:** one-tap alert with GPS coordinates to pre-set contacts
- **Live location sharing:** opt-in for trusted contacts during a run (secure WebSocket connections broadcasting position, heart rate, battery level)
- **Medical profile:** blood type, allergies, medications (lock-screen accessible)
- **Incident detection:** accelerometer + GPS fusion — sudden extreme deceleration spike followed by prolonged zero-movement triggers audible countdown → auto-alert if not cancelled

---

### Pillar 9 — Wearable Integration

**Phase 1 (BLE sensors — Phase 1 of development):** Direct BLE via `flutter_blue_plus` — heart rate straps, foot pods. Standard GATT UUIDs:

| GATT Service | UUID | Characteristic | UUID |
|---|---|---|---|
| Heart Rate | 0x180D | Heart Rate Measurement | 0x2A37 |
| Running Speed & Cadence | 0x1814 | RSC Measurement | 0x2A53 |
| Cycling Speed & Cadence | 0x1816 | CSC Measurement | 0x2A5B |
| Environmental Sensing | 0x181A | Temperature / Humidity | 0x2A6E / 0x2A6F |

**Phase 2 (Platform ingestion — Phase 4 of development):** Deploy self-hosted Open Wearables (MIT) to pull normalised activities from Apple Health, Google Health Connect, Garmin, Suunto, Polar, Strava, WHOOP, Samsung Health, and others. Users authenticate via OAuth; runs appear seamlessly in their feed.

**Background sync architecture** (from both research documents):
- iOS: HealthKit Observer Queries + BGTaskScheduler; Info.plist requires `UIBackgroundModes` (fetch, processing) and SDK background task identifiers
- Android: Health Connect API + WorkManager + foreground service (`FOREGROUND_SERVICE_DATA_SYNC` type)
- Anchored/delta queries only (sync tokens stored in Keychain / EncryptedSharedPreferences)

**Watch companion apps** (Wear OS, Apple Watch): later, conditional effort — only with dedicated community funding.

> ⚠️ **Open Wearables maturity note:** Before Phase 4, assess the project's commit activity and bus factor. If it stalls, fork it or fall back to a lightweight in-house ingestion adapter.

---

## 7. Technology Stack

| Layer | Technology | Rationale |
|---|---|---|
| Mobile App | Flutter (Dart) | Single codebase Android/iOS; excellent map & animation performance |
| GPS Engine | Native Flutter plugin (Kotlin/Swift) based on OpenTracks patterns | Apache-2.0 compatible; robust background execution |
| Local DB | SQLite via `drift` | Fast, complex queries for offline analytics |
| Maps | MapLibre GL + OpenStreetMap | Open-source, offline vector tiles (MBTiles/PMTiles), no commercial keys |
| Backend API | Go (primary) + Rust (spatial processing, FIT parsing) | High concurrency, simple ops |
| Database | PostgreSQL + PostGIS | Advanced spatial queries for routes, leaderboards |
| Cache & Real-time | Redis | Leaderboards, session cache, live activity sharing |
| Object Storage | MinIO (S3-compatible) | Self-hosted media, GPX exports, education content |
| Content CMS | Git-based Markdown or headless CMS (Strapi) | Easy contribution by non-coders |
| Auth (MVP) | Email/password + JWT (bcrypt, refresh tokens) | Minimal ops; OIDC added later when federated login needed |
| Wearable Ingestion* | Open Wearables (self-hosted, MIT) — Phase 4 only | Unified API; maturity assessed first |
| BLE Sensors | `flutter_blue_plus` | HR straps, foot pods |

**No AI/ML infrastructure.** Voice announcements are pre-recorded; milestone stories are template-based.

### Spatial Backend Detail (from both research docs)

- Trajectories stored as `LINESTRINGM` / `MULTILINESTRINGM` geometries (M-coordinate = UNIX timestamp)
- `geography` type for global spheroidal accuracy; `geometry` type for local speed
- GiST spatial indexing for millisecond query resolution
- Trajectory compression: moving-average window → Douglas-Peucker (`ST_Simplify`)
- Key spatial functions: `ST_Simplify`, `ST_DWithin`, `ST_Intersects`, `ST_MakeLine`

### Offline Map Architecture Detail (from both research docs)

- MBTiles: SQLite-packaged vector tiles; `sqflite` / `sqlite3` for tile blob retrieval
- TMS → XYZ coordinate flip in custom `TileProvider` (Y-axis inversion by zoom level)
- PMTiles: cloud-optimised archive; HTTP Range Requests directly from object storage (serverless, eliminates tile server costs)
- MapLibre parses MVT geometries and styles them client-side via JSON stylesheet

---

## 8. Development Roadmap — MVP-Driven, Conditional Phases

Phase 1 + Phase 2 form the **Minimum Lovable Product (MLP)**. Everything beyond is triggered by validated user demand, not a calendar.

### Phase 1 — Core Activity Tracker (Months 1–4)

**What we build:**
- Simple email/password + JWT authentication (no self-hosted identity server; OIDC deferred)
- User profiles, local auth, anonymous mode
- GPS engine (adaptive sampling, background recording, auto-pause, crash recovery) using OpenTracks patterns
- Live map & dashboard
- Activity history, PR detection
- GPX/FIT/TCX import/export (FIT via MIT-licensed Rust crate)
- Basic safety (SOS, location sharing)
- Offline-first architecture
- Starter challenges: "First Run", "First 5K", "7-Day Streak"
- One introductory education module: "How to Start Running"

**Deliverable:** Public beta on Play Store & TestFlight; first open-source release.

**Success Gate to Phase 2:**
- 3,000 monthly active users
- Median 8 runs/user/month over 90 days
- Positive retention and community signals

### Phase 2 — Education, Heritage & Full Motivation (Months 5–8)

**Trigger:** Phase 1 success gates met.

- Content platform: Running Science, Technique, Health courses
- Kenyan & East African Running Academy (history, camps, culture)
- East African Legends (first 20 interactive profiles)
- Full challenge library (distance, performance, seasonal, community-voted)
- Beat the Legends ghost-runner (5 initial legendary paces)
- Gamification system: XP, levels, badges, titles, streaks, leaderboards
- Template-based milestone stories
- Full Swahili support; offline content packs

**Deliverable:** The complete Mwendo experience — track, learn, challenge, celebrate heritage.

**Success Gate to further phases:**
- ≥30% of active users engage with education or challenges
- Top-voted features point clearly to schools/coach tools or wearables

### Phase 3 — Community & Organisational Tools (Conditional)

**Trigger:** Letters of intent from 3+ Kenyan schools/clubs; high demand.

- Schools Mode (teacher/student roles, attendance, house competitions, parental consent)
- Coach Portal (web): athlete management, manual workout assignments, progress dashboards
- Inter-school and club leaderboards (anonymised, opt-in)
- Incident detection with countdown alert
- National rankings infrastructure

### Phase 4 — Wearable Ecosystem (Conditional)

**Trigger:** >25% of users regularly use an external device; top-voted GitHub issue; Open Wearables confirmed healthy/maintained.

- Deploy self-hosted Open Wearables (or a fork) to ingest data from all major platforms
- Integrate BLE heart-rate monitor and foot pod support
- (Optional) Wear OS / Apple Watch companion apps — only with dedicated community funding

### Phase 5 — Continuous Enrichment (Ongoing)

- Expand Legends library via community contributions
- Translate content into more East African languages
- Improve offline maps via community mapathons
- Accessibility & performance hardening for low-end devices

---

## 9. Open-Source Strategy

| Aspect | Detail |
|---|---|
| Repository | Monorepo: `app/`, `backend/`, `packages/`, `docs/`, `tools/` |
| Client licence | MIT / Apache 2.0 (Flutter app, GPS plugin) |
| Server licence | AGPLv3 (Go, Rust) |
| Content licence | Creative Commons BY-SA 4.0 (education, maps, media) |
| Governance | Lightweight steering committee; public roadmap voting |
| Community | CONTRIBUTING.md, "good first issue" tags, Discord, monthly calls |

---

## 10. Success Metrics

| Category | Metric |
|---|---|
| Usage | DAU/MAU, runs recorded, total distance logged |
| Learning | Lessons completed, quiz scores, knowledge badges earned |
| Challenges | Started, completed, Beat the Legends attempts |
| Growth | Schools onboarded, coach accounts, active contributors |
| Retention | D1/D7/D30 rates; 90-day active cohorts |
| Satisfaction | App Store rating ≥ 4.5; community NPS |
| Health | GitHub stars, PRs merged, contributor diversity |

---

## 11. Contradictions Resolved

| Topic | Resolution |
|---|---|
| Sawe London 2026 1:59:30 | Flagged with ⚠️ — must verify against World Athletics ratification before publishing in-app |
| Open Wearables timing | Content Research placed it broadly; Dev Research placed it Phase 4. **Resolved: Phase 4**, with maturity assessment before adoption. BLE sensors (flutter_blue_plus) are available from Phase 1. |
| Kipyegon 1500m record venue/year | Content Research listed "Eugene, 2025" and also "2023." Dev Research omits the date. **Resolved: 3:48.68 at Eugene 2025** (per the more recent, specific citation). |
| Auth approach | Blueprint specified email/JWT. Neither research doc contradicted this. **Resolved: email/password + JWT for MVP; OIDC deferred.** |
| GPS plugin approach | Content Research mentioned Tracelet/Locus plugins; Dev Research and Blueprint specified a native Flutter plugin based on OpenTracks. **Resolved: native plugin (Kotlin/Swift)** — Tracelet/Locus are useful benchmarks only, not dependencies. |
| Roadmap length | Content Research didn't specify. Dev Research matched the Blueprint's 5-phase model. **Resolved: 5 phases, gated on success criteria.** |

---

## 12. Ultimate Goal

To create the world's leading open-source running platform — born in Kenya, inspired by East Africa's unmatched heritage, and trusted by millions everywhere. Mwendo will be the definitive place to track every stride, learn from the very best, and challenge yourself against legends. No AI coach. Just the wisdom of champions, the support of community, and the pride of carrying forward a running legacy that belongs to the world.

**Karibu Mwendo. Welcome to the journey.**
