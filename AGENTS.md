# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## Project

**catodo** (pubspec name; repo dir is `focuscope`) — a Flutter focus/study timer app with a
space-exploration game layer. Users run focus sessions; a Flame-rendered traveller flies through
space, unlocking characters and planets ("discoveries"). Local-first: all app data lives in an
Isar DB on-device. UI is Korean (comments and strings are largely in Korean).

## Commands

```bash
flutter pub get                                   # install deps
dart run build_runner build --delete-conflicting-outputs  # regenerate *.g.dart (Isar models)
flutter run                                       # run on connected device/emulator
flutter analyze                                   # static analysis / lints
flutter test                                      # tests
flutter build apk / flutter build ios             # release builds
```

Cloud Functions backend lives in `functions/` (TypeScript, Firebase, Node 22):

```bash
cd functions && npm run build      # tsc
cd functions && npm run deploy     # firebase deploy --only functions
```

**Codegen:** Isar models use `part '*.g.dart'`. After editing any `@collection` model, rerun
`build_runner`. **Localization:** ARB files in `lib/l10n/` (`app_en.arb`, `app_ko.arb`) generate
`AppLocalizations` (`flutter gen-l10n`, wired via `l10n.yaml` + `generate: true` in pubspec).

## Architecture

Loosely Clean-Architecture-flavored, organized under `lib/features/`:

- **data/** — `models/` (Isar `@collection` classes + generated `.g.dart`), `datasources/`
  (thin Isar CRUD wrappers), `repositories/` (business logic over datasources), `services/`
  (HTTP / external, e.g. `resource_update_service.dart`).
- **presentation/** — `viewmodels/` (state managers, see below), `views/` (Flutter widgets &
  overlays).
- **game/** — Flame game: `game_root.dart` (`FlameGame`), `components/` (home & timer worlds,
  traveller, planets, stars), `events/` (event bus + manager), and `*_manager.dart` singletons.
- **core/** — `db.dart` (Isar setup), `init_db.dart` (startup seeding), `observer.dart`,
  `utils/`.

### State management — custom singletons, NOT a package

There is **no Provider/Riverpod/Bloc**. State is hand-rolled:

- Each domain has a `XxxState` (immutable, `copyWith`) + `XxxManager` singleton
  (`static instance`, private `_internal()` ctor) holding the current state and a listener list.
  See `viewmodels/timer_state.dart`, `resource_version_state.dart`.
- `core/observer.dart` (`Observer<T>`) is the reusable base: `addListener(fn, {filter})` with
  optional conditional `filter`, and `notifyListeners(state)` that skips no-op updates. Managers
  either extend `Observer` or reimplement the listener pattern inline.
- Cross-cutting game reactions flow through `GameEventBus` (broadcast `Stream<GameEvent>`) and
  `GameEventManager`, which subscribes managers to each other (e.g. timer status → overlay/world
  changes).

When adding state, follow the existing pattern: immutable `State` + `copyWith`, singleton manager,
notify listeners on change. Don't introduce a state-management dependency.

### Repositories & datasources — lazy-initialized singletons

Repositories use a two-phase singleton: `initialize(dataSource)` (called once from
`DatabaseService.setUpDB`) then `.instance` getter that throws if not initialized. All wiring is
centralized in `core/db.dart` (`setUpDB`) — register new schemas in `Isar.open([...])` there and
add the datasource/repository init pair.

### Game layer (Flame)

`MainScreen` hosts a single `GameWidget(game: GameRoot())` with Flutter **overlays** keyed by the
`GameOverlay` enum (home, timer, focusEnd, ready, form). `GameRoot` swaps between `HomeWorld` and
`TimerWorld` via a shared `CameraComponent`. Game/UI communicate through the manager singletons
(`GameOverlayManager`, `GameWorldManager`, `CharacterManager`, `TimerManager`), not direct calls.

### Startup flow (`main.dart`)

`main()` → `MyApp._initializeApp()`: `initDB()` (open Isar, seed default characters/planets/
resource-version, load `.env`) → `initVersion()` → `versionCheck()` (compares local vs server
resource version, shows update dialog). Shows `SplashScreen` until initialized, then `MainScreen`.

### Resource versioning

App ships with default assets; additional characters/planets are downloaded on demand. The server
(Cloud Functions, `API_BASE_URL` in `.env`) exposes a resource version + resource list;
`ResourceUpdateService` downloads images to the app documents dir, and repositories persist them
into Isar. See `resource_version_repository.dart` / `resource_update_service.dart`.

## Conventions & gotchas

- **Firebase is currently disabled** — deps and init calls are commented out in `pubspec.yaml` /
  `init_db.dart`. The active backend is the plain HTTP Cloud Functions API via `http`.
- File naming is inconsistent (some `kebab-case`, some `snake_case`, e.g.
  `chacater-datasource.dart`, `characater_state.dart` — note the typos are real filenames). Match
  the existing name when importing; don't rename casually.
- Generated `*.g.dart` files are committed — regenerate rather than hand-edit.
- `.env` is git-ignored and required at runtime (`API_BASE_URL`); it's declared as a Flutter asset.
- Lints: default `flutter_lints` (`analysis_options.yaml`); `avoid_print` is on but `print` is
  used in some startup code.
- Comments and user-facing strings are predominantly Korean — keep new strings localized via ARB
  when they're user-facing.
