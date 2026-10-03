# SKILL.md — Manajemen Asrama

> Context brief for AI coding assistants (GitHub Copilot, etc.).
> Keep this file short, factual, and current. If something changes in the code,
> update this file in the same PR.

---

## 1. Project Summary

- **Name:** `manajemenasrama`
- **Purpose:** TODO — one sentence (e.g. "Dormitory management app for staff & residents: billing, rooms, activities, announcements").
- **Primary users:** TODO — (e.g. asrama admins + residents)
- **Status:** Early development / MVP / Production — TODO

## 2. Tech Stack

- **Framework:** Flutter (Dart SDK `^3.13.4`)
- **Target platforms:** Web (primary), Android. iOS = TODO (yes/no)
- **UI:** Material 3, custom theme in `lib/core/theme/app_theme.dart`
- **State management:** TODO — currently `setState` only; planned: `provider` / `riverpod` / `bloc`
- **Routing:** TODO — currently `home:` in `MaterialApp` + imperative `Navigator.push`. Planned: `go_router`?
- **Backend / Networking:** Custom backend API at `BACKEND_BASE_URL`
  (default `http://localhost:8877`). Uses `package:http`.
  - Auth: `POST /api/auth/login`
  - Register: `POST /api/auth/register`
  - User CRUD: `GET /api/users`, `GET /api/users/{id}`, `PUT /api/users/{id}`, `DELETE /api/users/{id}`
- **Auth model:** Users log in with **username + password**. Backend returns a
  bearer access token plus `expires_in`; the app stores the token locally and
  auto-logs out when it expires.
- **Session storage / TTL:** Session token is persisted by `shared_preferences`
  and the app schedules auto-logout from the backend `expires_in` value.
- **Testing:** `flutter_test`. Backend service tests use `http` `MockClient`.

## 3. Folder Layout

```
lib/
  main.dart                      # Initializes Supabase, mounts LoginPage in a 430px frame
  core/
    constants/app_colors.dart    # Color tokens
    backend/                      # HTTP client + backend config
    router/                      # (empty) go_router config goes here
    theme/app_theme.dart         # ThemeData (light). Dark theme = TODO
    validators/
      password_validator.dart    # Strong-password policy
  features/                      # Feature-first modules
    auth/
      login_page.dart            # Backend login form
      widgets/
    dashboard/
      dashboard_page.dart        # Entry point w/ users-management + logout
      widgets/
    users/
      users_page.dart            # List + delete via backend REST API
      user_form_page.dart        # Create / edit (register + update)
  services/
    auth_service.dart            # Wraps backend login/register; session persistence
    token_storage.dart           # shared_preferences-backed session storage
    user_service.dart            # backend CRUD on /api/users
  shared/
    models/
      app_user.dart              # Maps backend user payload → AppUser
      backend_session.dart       # Access token + expiry model
      user_role.dart             # enum Super Admin / Pengurus / Ustadzah
  widgets/                       # Reusable UI atoms
    activity_item.dart
    app_logo.dart
    balance_card.dart
    quick_action.dart
    stat_card.dart
test/
  widget_test.dart               # Smoke test — app boots to login
  password_validator_test.dart
  user_role_test.dart
```

### Conventions
- **File names:** `snake_case.dart`
- **Classes:** `PascalCase`
- **Feature-first:** new screens go under `lib/features/<feature>/`, their private widgets under `lib/features/<feature>/widgets/`.
- **Shared widgets:** only promote to `lib/widgets/` when used by 2+ features.
- Prefer `const` constructors.
- Null-safety: strict (default).
- Lints: `flutter_lints ^6.0.0` (see `analysis_options.yaml`).

## 4. Design System

- **Primary color:** TODO (see `app_colors.dart`)
- **Background frame color:** `0xFFE5E7EB` (used in `main.dart` as mobile-frame bg on web)
- **Max content width:** 430px (mobile-first; web just centers the mobile frame)
- **Typography:** Material default — TODO if custom font planned
- **Icon set:** Material + Cupertino (`cupertino_icons ^1.0.8`)

## 5. Runbook

Supabase credentials live in `env/dev.json` (git-ignored). A committed template
`env/dev.json.example` shows the required keys — copy it:

```powershell
Copy-Item env/dev.json.example env/dev.json
# then edit env/dev.json with real values from Supabase dashboard → Settings → API
```

Run / build using the env file (preferred — no secrets in your shell history):

```powershell
flutter pub get

# Dev run on web (reads env/dev.json)
flutter run -d chrome --dart-define-from-file=env/dev.json

# Dev run on Android
flutter run -d android --dart-define-from-file=env/dev.json

# Analyze & test (no backend credentials needed)
flutter analyze
flutter test

# Production build
flutter build web --release --dart-define-from-file=env/prod.json
```

VS Code: just press **F5** → picks `Flutter · Chrome (dev)` from
`.vscode/launch.json`, which already wires the env file.

JetBrains / Android Studio: *Run → Edit Configurations… → Additional run args* →
`--dart-define-from-file=env/dev.json`.

### Required keys in `env/*.json`
| Key | Where to find it | Required for |
|---|---|---|
| `BACKEND_BASE_URL` | Your backend service base URL | everything |

Docker (web via nginx): see `Dockerfile`, `docker-compose.yml`, `nginx.conf`.
```powershell
docker compose up --build
```

### Backend setup (one-time)
1. Start your API on `http://localhost:8877` (or change `BACKEND_BASE_URL`).
2. Make sure these endpoints exist:
   - `POST /api/auth/login`
   - `POST /api/auth/register`
   - `GET/PUT/DELETE /api/users`
3. Login returns `{ data: { access_token, token_type, expires_in, scope } }`.
4. `expires_in` is used for local auto-logout.

## 6. Don't Touch / Ignore

These paths are generated or platform-managed — do **not** edit, do **not** read for context:

- `build/**` (compiled output, including `build/web/main.dart.js`)
- `.dart_tool/**`
- `pubspec.lock`
- `android/gradle/**`, `android/gradlew*`, `android/.gradle/**`
- `web/icons/**` (static assets)
- Any `*.g.dart`, `*.freezed.dart`, `*.mocks.dart` (regenerate with build_runner)

## 7. Known Gaps / TODOs

- [ ] Choose + wire a state management solution
- [ ] Add `go_router` and move navigation out of `MaterialApp.home`
- [x] Replace `AuthService` mock with backend login/register
- [x] Add user CRUD + role dropdown via backend REST API
- [x] Sinkronisasi create/update user ke backend auth + user table
- [x] Add strong-password policy + validator
- [x] Remove Supabase dependency from client
- [ ] Add dark theme
- [ ] Add CI (GitHub Actions: `flutter analyze` + `flutter test`)
- [ ] Add backend service tests for login/register and users CRUD
- [ ] Model & screens for domain data (Penghuni, Kamar, Tagihan, Kegiatan)

## 8. Preferred AI Behavior

When helping on this repo:

- **Default to small, surgical edits.** Don't restructure folders unless asked.
- **Follow feature-first layout.** New screen? Create `lib/features/<name>/<name>_page.dart`.
- **Don't add new dependencies** without flagging it first with justification.
- **Prefer stdlib + Flutter built-ins** over new packages when reasonable.
- **Never read `build/**` or `*.lock`** — they are useless noise.
- **Run `flutter analyze`** (mentally or via terminal) after edits; fix lints you introduce.
- When unsure which state mgmt lib to use, ask once, then stick with the answer across the session.

## 9. Glossary (domain)

TODO — define recurring domain terms so the AI uses correct names:
- **Asrama:** dormitory
- **Penghuni:** resident
- **Kamar:** room
- **Tagihan:** bill / invoice
- **Kegiatan:** activity / event
- (add more…)

---

_Last updated: 2026-10-03_

