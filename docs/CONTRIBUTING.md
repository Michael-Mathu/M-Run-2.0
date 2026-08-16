# Mwendo Contribution Guidelines

Thank you for contributing to Mwendo! To maintain high mathematical precision, platform stability, and clean software architecture, please follow these formal guidelines.

---

## 1. Development Standards & Philosophy

We follow pragmatic software engineering principles:
* **YAGNI & Simplicity**: Write the minimum code required to solve the problem robustly. Avoid speculative abstractions.
* **Separation of Concerns**: Mathematical algorithms (GPS filtering, Kalman state tracking, split interpolation) must reside in pure Dart packages (`packages/gps_pipeline`), completely independent of Flutter UI dependencies.
* **Provable Provenance**: Never destructively overwrite raw sensor telemetry (`RawFix`). Display smoothing belongs in computed/derived representations.

---

## 2. Formatting & Linting

Before submitting any code, format and analyze the codebase:

```bash
# Format Flutter and pure Dart packages
dart format --line-length 100 .

# Format Go backend
cd backend && gofmt -s -w .

# Format Rust FFI crate
cd packages/mwendo_fit_parser/rust && cargo fmt

# Execute static analysis across the entire project
make analyze
```

---

## 3. Testing Requirements

All modifications must pass existing test suites and introduce tests for new logic:

```bash
# Run all client and backend tests
make test-all

# Run pure Dart GPS pipeline unit tests
cd packages/gps_pipeline && dart test

# Run Go backend test suite with race detection
cd backend && go test -v -race ./...
```

---

## 4. Git & Pull Request Lifecycle

### Branch Naming Conventions
* `feat/<feature-name>`: New feature implementations (e.g. `feat/cadence-filtering`)
* `fix/<bug-description>`: Bug fixes (e.g. `fix/stationary-drift-cluster`)
* `docs/<topic>`: Documentation updates
* `refactor/<scope>`: Code refactoring without behavior modification

### Conventional Commit Standards
Format commit messages using the Conventional Commits specification:
* `feat(pipeline): add 3-point lookahead spike rejection`
* `fix(engine): resolve race condition in serial command queue`
* `docs(api): document Douglas-Peucker simplify parameter`

### Pull Request Checklist
- [ ] Code is formatted (`dart format`, `gofmt`, `cargo fmt`).
- [ ] Static analysis produces zero warnings (`make analyze`).
- [ ] All unit and widget tests pass (`make test-all`).
- [ ] Drift schema migrations tested if database tables were modified.
- [ ] Documentation updated to reflect interface changes.
