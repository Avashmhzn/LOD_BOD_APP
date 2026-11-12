# LODBOD Shipper

LODBOD is a Flutter mobile app prototype for shippers to create and track loads,
review carrier bids, and manage shipment requests. It uses Firebase for account
authentication and shipment data, with Hive as a local shipment cache.

## Prerequisites

- Flutter compatible with Dart `3.14.0-53.0.dev` or later within the
  `pubspec.yaml` SDK constraint. The implementation was checked with Flutter
  `3.50.0-0.4.pre` and Dart `3.14.0-53.0.dev` (development-channel builds).
- Android Studio or Android SDK/JDK for Android builds, or Xcode for iOS builds.
- A configured Firebase project with Email/Password Authentication, Cloud
  Firestore, and the project's Android/iOS app configuration.
- A Firebase test account. No demo email/password is hardcoded in this repo.

## Setup and Run

From the project root:

```sh
flutter pub get
flutter run
```

The app uses the Firebase configuration in the repository. To use another
Firebase project, replace the platform configuration and regenerate
`lib/firebase_options.dart` with the FlutterFire CLI. Deploy compatible
Firestore rules before testing account-scoped shipment reads and writes.

To seed four fictional assessment shipments in an empty signed-in shipper
account, including two example bids on `LOD-1002`, run against a development
Firebase project:

```sh
flutter run --dart-define=ENABLE_DEMO_FIXTURES=true
```

Fixture seeding is off by default and writes to Firestore; it is not an
in-memory mock. It only seeds when the signed-in shipper has no shipments.

## Demo Access

There are no repository-provided demo credentials. Sign in with an email and
password for an account in the configured Firebase project. Phone login also
requires a phone-to-email lookup record created by the app's account flow.

## Implemented Features

- Email or phone login with validation, password visibility toggle, and loading
  and error states.
- Dashboard metrics for active, awaiting-bid, and completed shipments, plus
  recent shipments and the mobile request counter.
- Shipment list with search and status/date filters, reusable shipment cards,
  and shipment details.
- Four-step shipment creation flow: route, cargo, truck requirements, and
  review; supports saving drafts.
- Mobile limit of three qualifying shipment requests, with this limit message:
  “You have reached the mobile request limit of 3. Please use the LODBOD web
  platform to create additional requests.”
- Bid review and confirmation-based bid acceptance. Seeded `LOD-1002` has two
  fictional example bids.
- Shared Firestore shipment state is reloaded across dashboard, list, and detail
  views after shipment changes.
- Bottom navigation for Home, Shipments, Post Load, Analytics, and Account.
- Illustrative shipment route/status tracking; no live GPS integration.

## Architecture and State

The code is organized feature-first under `lib/features/`, with `data`,
`domain`, and `presentation` layers where applicable. Shared routing,
dependency injection, utilities, and widgets live under `lib/core/`.

Flutter BLoC manages authentication, dashboard, shipment queries, create
submission, and bid actions. Some view-only behavior, including filters and
multi-step form fields, remains in widget state. `get_it` wires dependencies
and `go_router` handles navigation. Shipment operations are expressed through
use cases and the `ShipmentRepository` interface.

Firebase Auth and Cloud Firestore provide authentication and remote shipment
storage. Hive caches shipment data per signed-in user; Firebase Auth retains
the login session. This is not a local-only persistence model, and cached reads
do not currently expose a freshness indicator.

## Build and Device Run

List connected devices and run on one:

```sh
flutter devices
flutter run -d <device-id>
```

Build a release APK:

```sh
flutter build apk --release
```

The APK is written under `build/app/outputs/flutter-apk/`. For an iOS device,
build and sign through Xcode or use `flutter build ios` on macOS.

## Tests

Run the Dart and Flutter test suite with:

```sh
flutter test
```

Current tests cover the splash widget, shipment serialization, bid fixtures,
shipment references and route ordering, currency formatting, and the bid
acceptance use-case contract. They do not exercise Firebase rules, transaction
races, or the three-request create guard end to end.

## Known Limitations

- The three-request cap is a client-side check against the currently fetched
  shipment list. It is not an atomic server-enforced quota and may be bypassed
  by concurrent clients or direct API access.
- Bid submission calls a `placeShipmentBid` Firebase callable, but Cloud
  Functions source is not included in this workspace. Carrier bid submission
  therefore requires a compatible callable to be deployed separately.
- Bid acceptance uses a Firestore transaction and the included Firestore rules;
  emulator integration and concurrency tests are not included.
- Shipment writes require connectivity and are not queued for later sync.
- Demo bids are fictional examples. Tracking routes and progress are
  illustrative, not live location data.
- The Analytics destination currently opens a placeholder screen; analytics
	reporting is not implemented.
- OTP resend is not implemented yet; the current event only writes a log entry.

See [TECHNICAL_NOTE.md](TECHNICAL_NOTE.md) for implementation choices and
backend boundaries.
