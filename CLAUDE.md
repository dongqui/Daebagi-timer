# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**catodo** (pubspec name; repo dir is `focuscope`; product name "대박이 타이머" / Focuscope) — a
Flutter focus/study timer with a space-exploration game layer. Users run focus sessions; a
Flame-rendered traveller flies through space, and accumulated focus time discovers planets.
Sessions are recorded per activity and shown as day/week/month/year stats.

Primary target is an **Apps in Toss (앱인토스) mini-app**: a Flutter Web build served inside the
Toss app's WebView. Android/iOS native builds are kept from the same codebase. Local-first: all
data lives on-device behind a `KeyValueStore` abstraction (no DB package, no backend). UI is
dark-only and built on Toss Design System (TDS) tokens. Comments and strings are predominantly
Korean. README.md is accurate and has architecture diagrams — read it first.

## Commands

```bash
flutter pub get
flutter gen-l10n                       # regenerate AppLocalizations from lib/l10n/*.arb
flutter run                            # native device/emulator
flutter run -d chrome                  # web in a browser
flutter analyze
flutter test                           # 90+ tests (storage, managers, navigation, alert, TDS widgets)
flutter build apk / flutter build ios  # native release builds
```

Apps in Toss bundle (Node tooling in `package.json`):

```bash
npm install
npm run build:sdk    # esbuild toss/apps_in_toss_entry.js → web/js/apps_in_toss.js (IIFE, global AppsInTossModule)
npm run build:web    # flutter build web --release
npm run build        # build:sdk + build:web + `ait build` (reads apps-in-toss.config.ts, outputs *.ait)
npm run deploy       # ait deploy (needs console API key)
```

`.claude/launch.json` defines a `web` preview config (`flutter run -d web-server` on port 8088).

**Localization:** ARB files in `lib/l10n/` (`app_en.arb` template, `app_ko.arb`) generate
`AppLocalizations` via `flutter gen-l10n` (`l10n.yaml` + `generate: true` in pubspec). Import as
`package:flutter_gen/gen_l10n/app_localizations.dart`.

No codegen beyond l10n — models are hand-written `fromJson`/`toJson`, there are no `*.g.dart`
files.

## Architecture

Loosely Clean-Architecture-flavored, organized under `lib/`:

- **core/** — `observer.dart` (`Observer<T>` base), `storage/` (persistence layer, below),
  `navigation/` (back-button handling), `toss_*.dart` (platform bridges, below), `db.dart`
  (storage assembly), `init_db.dart` (startup seeding), `boot_screen*.dart`, `utils/`.
- **features/data/** — `models/` (plain Dart classes with `fromJson`/`toJson`, nullable `int? id`),
  `datasources/` (thin wrappers over a `DocumentStore<T>`), `repositories/` (business logic over
  datasources).
- **features/presentation/** — `viewmodels/` (State + Manager pairs: timer, character, discovery,
  form, chart, audio, `focus_end_alert.dart`), `views/` (Flame overlays, stats, settings).
- **features/game/** — Flame: `game_root.dart` (`FlameGame`), `components/home/` & `components/timer/`
  (worlds, traveller, parallax stars, planet, flowstar), `events/` (event bus + `GameEventManager`),
  `game_overlay_manager.dart`, `game_world_manager.dart`.
- **theme/** — TDS tokens (`tds_colors.dart`, `tds_metrics.dart`, `tds_typography.dart`,
  `app_theme.dart`).
- **widgets/tds/** — TDS components ported to Flutter (`TdsButton`, `TdsTextField`,
  `TdsSegmentedControl`, `TdsNavigation`, `TdsListRow`, `TdsGlassPanel`, `TdsBottomCta`, …).
  `widgets/` also holds app-specific pieces (`space_backdrop.dart`, `full_screen_overlay.dart`).
- **l10n/**, **constants/**, **extensions/**.

### State management — custom singletons, NOT a package

There is **no Provider/Riverpod/Bloc**. State is hand-rolled:

- Each domain has a `XxxState` (immutable, `copyWith`) + `XxxManager` singleton
  (`static instance`, private `_internal()` ctor) holding the current state and a listener list.
  See `viewmodels/timer_state.dart`, `characater_state.dart`, `discovery_state.dart`.
- `core/observer.dart` (`Observer<T>`) is the reusable base: `addListener(fn, {filter})` with an
  optional conditional `filter`, and `notifyListeners(state)` that skips no-op updates. Managers
  either extend `Observer` or reimplement the listener pattern inline.
- `TimerManager` exposes two listener kinds: full-state (fires every second) and status-only
  (fires on `TimerStatus` transitions: idle / ready / running / paused / input / end).
- Cross-cutting game reactions flow through `GameEventBus` (broadcast `Stream<GameEvent>`) and
  `GameEventManager`, which subscribes the Flame side to managers in one place (timer status →
  `GameOverlayManager` swaps overlays, `GameWorldManager` swaps worlds).
- Widgets: `addListener` in `initState`, `removeListener` in `dispose`, `setState` in the callback.
  Screens that subscribe to several managers reuse the abstract `ProgressState`
  (`views/overlays/progress_state.dart`).

When adding state, follow the existing pattern: immutable `State` + `copyWith`, singleton manager,
notify listeners on change. Don't introduce a state-management dependency.

### Storage — `KeyValueStore` → `DocumentStore<T>` → DataSource → Repository

Isar was removed during the Toss port: in the Toss WebView, IndexedDB (which every Dart web DB
sits on) is wiped by iOS after 7 days without a visit. Persistence now goes through the Apps in
Toss native Storage bridge, which is **string-only**, and the layer is designed around that.

- `core/storage/key_value_store.dart` — `KeyValueStore`: `init / read / write / delete`, String
  values only. Two implementations: `TossStorageStore` (`dart:js_interop` over
  `AppsInTossModule.Storage`, web-only via conditional import) and `SharedPreferencesStore`.
- `core/storage/store_selector.dart` — `createDefaultKeyValueStore()` picks the backend at
  runtime. Toss WebView + SDK present → `TossStorageStore`; otherwise `SharedPreferencesStore`.
  Toss WebView *without* the SDK bundle logs a loud warning (fallback is localStorage, which iOS
  deletes). All parameters are test-injection hooks.
- `core/storage/document_store.dart` — `DocumentStore<T>`: one collection = one key holding the
  **entire JSON array**; every write re-serializes the collection (fine at this app's scale,
  not for tens of thousands of rows). `load()` fills an in-memory cache once; after that
  `query({where, sort})`, `getById`, `count` are **synchronous** and return copies. Auto-increment
  ids live in a separate `<collection>__seq` key so deleted ids are never reused. Pure Dart —
  unit-tested with `test/support/in_memory_key_value_store.dart` and `loadedStore()` from
  `test/support/test_stores.dart`.
- `core/db.dart` (`DatabaseService.setUpDB`) is the single assembly point: build each
  `DocumentStore<T>` (`toJson/fromJson/getId/setId`), `await` all `load()`s, then construct
  datasources and call `XxxRepository.initialize(ds)`. Repositories are two-phase singletons:
  `initialize(dataSource)` once, then `.instance` (throws if not initialized).

**To add a collection:** write the model with `int? id` + `fromJson`/`toJson`, add a
`DocumentStore` + datasource + repository init pair in `db.dart`, seed defaults in `init_db.dart`
if needed, and add a JSON round-trip test (`test/features/data/models/json_round_trip_test.dart`).

### Apps in Toss integration

The SDK (`@apps-in-toss/web-framework` 3.1.1) is bundled by esbuild from
`toss/apps_in_toss_entry.js` into `web/js/apps_in_toss.js`, loaded **synchronously** in
`web/index.html` before Flutter starts, and exposed as the global `AppsInTossModule`. Dart reaches
it through `dart:js_interop` extension types. Every bridge uses the same conditional-import
pattern so native builds compile:

```dart
export 'xxx_stub.dart' if (dart.library.js_interop) 'xxx_web.dart';
```

- Toss-WebView detection is `window.ReactNativeWebView != null` (the SDK bundle also loads in
  plain browsers, so module presence alone proves nothing).
- `core/storage/toss_storage_store*.dart` — `Storage.getItem/setItem/removeItem`.
- `core/toss_haptic*.dart` — `Device.triggerHaptic`; the SDK takes no duration, so a long alert
  vibration is faked by repeating short pulses. Plain browsers use `navigator.vibrate`.
- `core/toss_safe_area*.dart` — `SafeArea.get()`; Flutter Web reports zero `MediaQuery.padding`
  inside the WebView, so `TossSafeArea` (applied once in `MaterialApp.builder`) injects the SDK
  insets. Nav-bar height is deliberately *not* added: the bar is transparent and only its right
  end is used by Toss, so app buttons go on the left (`TdsNavigation.leftItems`).
- `core/navigation/` — `TossBackBridge` subscribes to `graniteEvent.backEvent` and calls
  `closeView()`; `AppBackDispatcher` is a handler stack (dialogs → pushed overlay handlers →
  exit). `AppBackBinding.ensureStarted` wires it once from `MainScreen`; back never exits the
  mini-app while a focus session is active.
- `core/boot_screen*.dart` — calls `window.hideBootScreen()` defined in `index.html` after the
  first frame.
- `web/flutter_bootstrap.js` pins CanvasKit to the bundled `canvaskit/` path (no gstatic CDN —
  Toss bundle uploads may block external hosts).
- `apps-in-toss.config.ts` — `appName: "focuscope"`, dark transparent nav bar with no Toss
  buttons, pull-to-refresh and bounce off (refresh would reset a running timer). Note the comment
  there: the served Origin depends on the SDK major/minor version, so bumping it after launch
  needs `Migration.getOriginStorage()` for localStorage/IndexedDB data.

### UI — TDS tokens and widgets

The app is dark-only. Colors, radii, spacing, sizes, blur and motion are Dart constants in
`lib/theme/` (`TdsColors`, `TdsRadius`, `TdsSpacing`, `TdsSize`, `TdsBlur`, `TdsMotion`,
`TdsText`), copied from the TDS Figma variables — do not eyeball-adjust them, and do not write
raw `Color(0x…)` or pixel values in views. `AppTheme.dark` only tunes Material defaults (dialogs,
dividers, selection) so that stray Material widgets don't clash; screens use `lib/widgets/tds/`
widgets directly. Text drawn over the game canvas uses the `TdsColors.onCanvas*` white-alpha
series instead of the semantic text tokens. Add new UI by reusing or extending a `Tds*` widget
rather than hand-styling; widget tests live in `test/widgets/tds_widgets_test.dart`.

### Game layer (Flame)

`MainScreen` hosts a single `GameWidget(game: GameRoot())` with Flutter **overlays** keyed by the
`GameOverlay` enum (home, timer, form, focusEnd, ready; `audio`/`login` exist but aren't mounted).
`GameRoot` swaps between `HomeWorld` and `TimerWorld` via a shared `CameraComponent`. Game and UI
never call each other directly — both observe the manager singletons (`TimerManager`,
`CharacterManager`, `GameOverlayManager`, `GameWorldManager`).

### Startup flow (`main.dart`)

`main()` enables wakelock (failure swallowed — WebViews may lack the API) → `runApp` →
`initDB()` (`DatabaseService.setUpDB()` then seed default characters, selected character, and
planets) → `SplashScreen` plays the intro until both init and the intro animation finish →
`MainScreen`. `hideBootScreen()` runs after the first frame.

## Conventions & gotchas

- **Legacy leftovers:** `functions/`, `firebase.json`, `firestore.*`, `storage.rules`,
  `.firebaserc`, `.env` and `views/login.dart` are remnants of a removed Firebase/Cloud Functions
  backend. Nothing in `lib/` uses them; Firebase deps are commented out in `pubspec.yaml`. Don't
  build on them.
- File naming is inconsistent (`chacater-datasource.dart`, `characater_state.dart`,
  `latest-activity-model.dart` — the typos are real filenames). Match the existing name when
  importing; don't rename casually.
- `pubspec.yaml` lists asset directories explicitly (no `assets/images/` wildcard). Intro images
  referenced from `web/index.html` must stay registered even if Dart doesn't use them.
- Anything touching `dart:js_interop` must live in a `*_web.dart` behind a stub + conditional
  export, or native builds break.
- `DocumentStore` reads are synchronous only after `load()`; `setUpDB` awaits all loads before
  constructing datasources. Keep that ordering.
- Lints: default `flutter_lints` (`analysis_options.yaml`); `avoid_print` is on, so use
  `debugPrint` (a couple of `// ignore: avoid_print` exist in bridge code).
- Comments and user-facing strings are Korean — add user-facing strings to both ARB files and run
  `flutter gen-l10n`.
- `.claude/settings.local.json`, `*.ait`, `node_modules/`, `.env` are git-ignored local files.
  `.codex/` is currently untracked (Codex tool config).
