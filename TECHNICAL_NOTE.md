# Technical Note

## Data Flow

Presentation widgets dispatch events to feature BLoCs or invoke view-local
state for transient interactions. BLoCs call domain use cases, which depend on
repository interfaces. The shipment repository implementation coordinates the
Firestore remote data source, Hive cache, and connectivity status. Results
are mapped to shipment entities and emitted back as UI state. Firebase Auth
maintains the signed-in session; Firestore stores the shared shipment records.

```text
Widget -> BLoC -> Use case -> Repository interface
                              -> Firestore data source
                              -> Hive cache
```

## Repository Design and API Replacement

`ShipmentRepository` is the domain boundary. `ShipmentRepositoryImpl` currently
uses `ShipmentRemoteDataSourceImpl` for Firestore and Cloud Functions calls,
plus `ShipmentLocalDataSourceImpl` for Hive caching. To move to REST, implement
the remote data-source contract with an HTTP client, map response payloads to
the existing shipment models/entities, and register the replacement in
`core/di/injection_container.dart`. Domain use cases and most presentation
code can remain unchanged. Authentication has a separate repository and
Firebase-backed data source.

The assessment fixtures are Firestore seed data enabled through
`ENABLE_DEMO_FIXTURES`; they are not a mock repository and should only be used
with a development Firebase project.

## Safeguards and Boundaries

- **Three-request mobile limit:** `CreateShipmentBloc` fetches shipments and
  counts qualifying statuses before a non-draft create. At three, it returns
  the required message directing the user to the LODBOD web platform. The
  dashboard uses the same qualifying status set for its counter. Because the
  authoritative check is currently in the client, this is a UX limit rather
  than a secure quota; concurrent submissions and direct writes are not
  atomically capped by the included Firestore rules.
- **Bid acceptance:** the detail UI asks for confirmation. The use case checks
  that the selected bid is among the displayed bids, then the data source
  performs a Firestore transaction. It rejects missing shipments, bids not
  present in stored/approved fixture data, and shipments that are no longer
  open. The included Firestore rules further constrain the accepted bid,
  assigned carrier, fare, status transition, and changed fields. Repeating the
  same accepted bid is treated as idempotent.
- **Bid submission:** the app calls `placeShipmentBid` through Firebase
  Callable Functions. The function source is not present in this workspace, so
  any server-side bid-count or retry guarantees depend on the separately
  deployed callable implementation and are not claimed as locally verified.

## Trade-offs and Persistence

Firebase kept authentication and shared shipment changes available across
sessions and devices without building a custom API for the assignment. Hive
provides a lightweight per-user cache, but it does not provide a complete
offline write queue or a visible cache-freshness policy. Shipment creation
reuses an ID while a form remains open to reduce duplicate creation on retry;
this is not a durable, cross-device idempotency mechanism.

BLoC and use cases keep major state transitions and domain operations out of
the UI, while local form-step and filter state stays close to the widgets.
That keeps the prototype practical, but presentation state is not uniformly
managed through BLoC.

## Packages and Tests

- `flutter_bloc` and `equatable`: event/state flow and value equality.
- `get_it`: dependency registration.
- `go_router`: route definitions and navigation.
- `firebase_auth`, `cloud_firestore`, `cloud_functions`: account and remote
  operations.
- `hive` / `hive_flutter`: local shipment cache.
- `dartz`: repository result values; `intl`: date/number formatting.
- `flutter_test`, `bloc_test`, and `mocktail`: test dependencies.

Tests cover shipment model conversion, fixture selection, references, route
ordering, currency formatting, the bid acceptance use-case contract, and the
splash screen. There are no Firebase Emulator tests or direct tests for the
three-request guard and Firestore rules.

The Analytics route currently renders a placeholder, and OTP resend is a log
only; neither flow has a complete implementation yet.

## One More Day

I would move the three-request limit to an authenticated server transaction so
it remains correct under concurrent requests, add Firebase Emulator tests for
the security rules and bid-acceptance races, and test the create guard at the
BLoC level. I would also add pagination and explicit cache freshness/error
states, then validate the callable contract and document a dedicated Firebase
assessment-account setup flow.