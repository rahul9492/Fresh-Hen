# FreshHen

FreshHen is a Flutter mobile app for ordering fresh chicken and eggs. Users can browse products, filter and search, add items to a cart, manage delivery addresses, check out with Cash on Delivery or UPI (scan the store's QR and upload a payment screenshot), and track, rate and repeat their orders.

> **Status:** The app runs on **mock data** by default. The network layer (`core/network`) and `auth` already have a real `RemoteAuthRepository`; other features get theirs as the backend lands.

- App ID: `com.freshhen.app`
- Version: `1.0.0+1`
- Platforms: Android and iOS (portrait only)

## Features

- Onboarding, then phone + OTP login, then profile setup
- Home with promo carousel and category strip
- Categories, product list, search, filters and product detail
- Cart with product options (e.g. weight/cut), special instructions and coupons
- Address book: Home / Work / Other, default address, saved per user on the device
- Delivery timing: "Order now" (ETA from store settings) or "Schedule for later" with a slot picker, shown only when the admin switches scheduling on
- Payment: Cash on Delivery, or UPI by scanning the admin-uploaded QR and uploading a screenshot (gallery or camera) as proof
- Order placed screen, orders list with search, order summary, repeat order
- Tax invoice as a PDF (share / save) and "Rate your experience" (stars + comment)
- Help & Support with Call and WhatsApp buttons
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
| Payment screenshot (gallery / camera) | `image_picker` |
| PDF invoice and share sheet | `pdf`, `printing` |
| Dialer and WhatsApp links | `url_launcher` |
| WhatsApp icon | `font_awesome_flutter` |

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

One flag decides it, set at build time (see `lib/core/config/env.dart`). The default depends on the build mode:

| Build | Default | Why |
| --- | --- | --- |
| `flutter run` (debug) | **mock** data | develop without a backend |
| `flutter build ... --release` | **real** backend | a store build must never accept the fake OTP `1234` |

```bash
# debug: mock data (default)
flutter run

# debug: real backend
flutter run --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=https://your-api/v1
```

> **Important:** until the backend is live, a plain release build **cannot log in** (it calls the real API). Build test APKs with `--dart-define=USE_MOCK=true`; see [Build Commands](#build-commands).

Mock-only switches:

| Flag | Default | Effect |
| --- | --- | --- |
| `MOCK_SCHEDULE` | `true` | Mirrors the admin "Schedule for later" switch. `--dart-define=MOCK_SCHEDULE=false` shows "Order now" only. |

Checkout data the admin app controls (schedule switch, UPI QR and UPI ID, ETA, fees, invoice details) comes from `GET /store/settings`; the expected API shapes are documented at the top of `lib/features/checkout/repositories/checkout_repository.dart`. Orders are mock-only for now.

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
# Test APK that behaves like `flutter run` (mock data, OTP 1234)
flutter build apk --release --dart-define=USE_MOCK=true

# APK against the real backend (once it is live)
flutter build apk --release --dart-define=API_BASE_URL=https://your-api/v1

# App Bundle for Google Play Store (real backend)
flutter build appbundle --release --dart-define=API_BASE_URL=https://your-api/v1
```

> In release builds the OTP hint on the OTP screen is hidden; with `USE_MOCK=true` the OTP is still `1234`. Fonts are downloaded on first launch, so the first open needs internet.

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
│   ├── constants/         # App-wide constants (mock OTP, latency, support phone, ...)
│   ├── errors/            # AppException
│   ├── media/             # pickImage() + PickedImage: gallery / camera picking
│   ├── storage/           # SharedPreferences provider
│   ├── utils/             # Formatters, validators, context extensions
│   └── widgets/           # Reusable widgets (buttons, text fields, ...)
└── features/
    ├── onboarding/        # Intro slides
    ├── auth/              # Login, OTP, profile setup
    ├── home/              # Home, categories, search, product list, bottom-nav shell
    ├── catalog/           # Products, product detail, filters, mock catalog data
    ├── cart/              # Cart state and screen (checkout steps)
    ├── address/           # Address book, form and picker sheets
    ├── checkout/          # Store settings, coupons, slots, payment method, UPI payment screen
    ├── orders/            # Orders list, summary, success, invoice PDF, rating
    └── account/           # Account menu, Help & Support, info pages

assets/
├── images/                # Product and onboarding images, sample UPI QR (registered in pubspec.yaml)
├── fonts/                 # Noto Sans, used in the PDF invoice (has the ₹ sign)
└── icon/                  # App icon and splash source images

test/flow_test.dart        # App flow test
test/checkout_test.dart    # Checkout rules and order placement
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
- `widgets/`: reusable UI. Use these instead of building new ones: `showAppSheet` + `AppSheet`, `FilterSheetScaffold`, `ChoiceChipGroup`, `AppliedFiltersRow`, `AppSearchBar`, `FilterButton`, `showConfirmDialog`, `LoadingOverlay`, `PaginatedListView`, `ErrorView`, `AsyncView`, `ShimmerBox`, `AppImage`, `PriceText`, `StatusChip`, `AppScaffold`, `AppCard`, `BottomActionBar`, `DashedDivider`, `ImageUploadButton` (gallery button + camera button)
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
