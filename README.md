# FreshHen

FreshHen is a Flutter mobile app for ordering fresh chicken and eggs. Users can browse products, filter and search, add items to a cart, manage delivery addresses, place orders and view order history.

> **Status:** The app runs on **mock data** by default. The network layer (`core/network`) and `auth` already have a real `RemoteAuthRepository`; other features get theirs as the backend lands.

- App ID: `com.freshhen.app`
- Version: `1.0.0+1`
- Platforms: Android and iOS (portrait only)

## Features

- Onboarding, then phone + OTP login, then profile setup
- Home with promo carousel and category strip
- Categories, product list, search, filters and product detail
- Cart with product options (e.g. weight/cut)
- Address management (add, edit, delete)
- Orders list and order success screen
- Account screen and info pages

## Tech Stack

| Purpose | Package |
| --- | --- |
| State management | `flutter_riverpod` + `riverpod_annotation` (code generated) |
| Navigation | `go_router` |
| Immutable models | `freezed`, `json_serializable` |
| Local storage | `shared_preferences` |
| Fonts | `google_fonts` |
| Formatting | `intl` |

## Prerequisites

1. [Flutter SDK](https://docs.flutter.dev/get-started/install) with Dart `^3.13.1` (run `flutter --version` to check)
2. Android Studio (Android SDK and an emulator) and/or Xcode (iOS, macOS only)
3. Run `flutter doctor` and fix anything it reports

## Quick Start

```bash
# 1. Install dependencies
flutter pub get

# 2. Generate code (only needed if *.g.dart / *.freezed.dart are missing or you changed models/providers)
dart run build_runner build --delete-conflicting-outputs

# 3. Run on a connected device or emulator
flutter run
```

**Test login:** enter any phone number. The OTP is `1234` (set as `mockOtp` in `lib/core/constants/app_constants.dart`).

## Mock vs Real Backend

One flag decides it, set at build time (see `lib/core/config/env.dart`):

```bash
# mock data (default)
flutter run

# real backend
flutter run --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=https://your-api/v1
```

## Common Commands

| Task | Command |
| --- | --- |
| Install dependencies | `flutter pub get` |
| Run app (debug) | `flutter run` |
| List devices | `flutter devices` |
| Generate code once | `dart run build_runner build --delete-conflicting-outputs` |
| Generate code on save | `dart run build_runner watch --delete-conflicting-outputs` |
| Run tests | `flutter test` |
| Static analysis / lint | `flutter analyze` |
| Format code | `dart format lib test` |
| Regenerate app icons | `dart run flutter_launcher_icons` |
| Regenerate splash screen | `dart run flutter_native_splash:create` |
| Clean build | `flutter clean && flutter pub get` |

## Build Commands

### Android

```bash
# APK (for direct install / testing)
flutter build apk --release

# App Bundle (for Google Play Store)
flutter build appbundle --release
```

Output:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

> **Note:** Release builds are currently signed with the **debug key** (see `android/app/build.gradle.kts`). Before publishing to the Play Store, create your own keystore and configure a release `signingConfig`.

### iOS (requires a Mac with Xcode)

```bash
flutter build ios --release      # build the app
flutter build ipa                # build an .ipa for App Store / TestFlight
```

You need an Apple Developer account and signing set up in Xcode (`ios/Runner.xcworkspace`).

## Project Structure

The code is organised **by feature**. Each feature keeps its own models, providers, screens and widgets.

```
lib/
├── main.dart              # Entry point: sets up SharedPreferences + Riverpod
├── app/
│   ├── app.dart           # Root MaterialApp.router
│   ├── router/            # go_router setup and route names
│   └── theme/             # Colors and theme
├── core/                  # Shared code used by all features
│   ├── constants/         # App-wide constants (mock OTP, latency, ...)
│   ├── errors/            # AppException
│   ├── storage/           # SharedPreferences provider
│   ├── utils/             # Formatters, validators, context extensions
│   └── widgets/           # Reusable widgets (buttons, text fields, ...)
└── features/
    ├── onboarding/        # Intro slides
    ├── auth/              # Login, OTP, profile setup
    ├── home/              # Home, categories, search, product list, bottom-nav shell
    ├── catalog/           # Products, product detail, filters, mock catalog data
    ├── cart/              # Cart state and screen
    ├── address/           # Address list and form
    ├── orders/            # Orders and success screen
    └── account/           # Account menu and info pages

assets/
├── images/                # Product and onboarding images (registered in pubspec.yaml)
└── icon/                  # App icon and splash source images

test/flow_test.dart        # App flow test
```

Inside a feature, the folders mean:
- `models/`: data classes (Freezed)
- `providers/`: Riverpod state and logic
- `repositories/`: data access (currently mock implementations)
- `screens/`: full pages
- `widgets/`: smaller UI pieces used by that feature

## Generated Files (Important)

Files ending in `.g.dart` and `.freezed.dart` are **generated** by `build_runner`. **Do not edit them by hand.** After changing a Freezed model, a `@riverpod` provider or a route, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

If you see errors like `Target of URI doesn't exist: '...g.dart'`, run the command above.

## Feature Layout (per feature)

```
features/<feature>/
├── models/          # freezed + json, shaped like the API
├── repositories/
│   ├── <x>_repository.dart          # interface
│   ├── mock_<x>_repository.dart     # works offline
│   └── remote_<x>_repository.dart   # Dio calls
├── providers/
│   ├── <x>_repository_provider.dart # picks mock or remote from Env.useMock
│   └── <x>_provider.dart            # state and logic used by screens
├── screens/
└── widgets/
```

`auth` is the reference implementation. Screens talk to providers, providers talk to the repository interface, never to Dio or mock data.

## Shared Code (`lib/core`)

- `config/env.dart`: `useMock`, `baseUrl`
- `network/`: Dio client, token interceptor, 401 handling (`sessionExpired`), `apiCall()` error mapping, `endpoints.dart`
- `storage/token_store.dart`: saved login token
- `models/paginated.dart`: page of a list
- `widgets/`: reusable UI. Use these instead of building new ones: `showAppSheet` + `AppSheet`, `FilterSheetScaffold`, `ChoiceChipGroup`, `AppliedFiltersRow`, `AppSearchBar`, `FilterButton`, `showConfirmDialog`, `LoadingOverlay`, `PaginatedListView`, `ErrorView`, `AsyncView`, `ShimmerBox`, `AppImage`, `PriceText`, `StatusChip`, `AppScaffold`
- Feedback: `context.showSnack / showSuccess / showError`

## Connecting a Feature to the Backend

1. Add its paths to `core/network/endpoints.dart`.
2. Write `remote_<x>_repository.dart` (wrap calls in `apiCall(...)`).
3. Return it from `<x>_repository_provider.dart` when `Env.useMock` is false.
4. Adjust model field names if the API differs.

Auth API shape assumed today is documented in `features/auth/models/auth_session_model.dart`.

## Troubleshooting

- **Build fails after pulling changes:** run `flutter pub get`, then the `build_runner` command.
- **Weird cached errors:** run `flutter clean`, then `flutter pub get`.
- **No devices found:** start an emulator from Android Studio, or plug in a phone with USB debugging on, then check `flutter devices`.
- **Missing icon or splash changes:** re-run the icon and splash commands from the table above.

## Learn More

- [Flutter documentation](https://docs.flutter.dev/)
- [Riverpod](https://riverpod.dev/)
- [go_router](https://pub.dev/packages/go_router)
- [Freezed](https://pub.dev/packages/freezed)
