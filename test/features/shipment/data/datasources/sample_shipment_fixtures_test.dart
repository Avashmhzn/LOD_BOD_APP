import 'package:flutter_test/flutter_test.dart';
import 'package:lodbod_app/features/shipment/data/datasources/sample_shipment_fixtures.dart';

void main() {
  test('provides LOD-1001 through LOD-1004 demo shipments', () {
    final fixtures = SampleShipmentFixtures.forUser(
      'demo-user',
      now: DateTime.utc(2026, 11, 10),
    );

    expect(fixtures.map((shipment) => shipment.reference), [
      'LOD-1001',
      'LOD-1002',
      'LOD-1003',
      'LOD-1004',
    ]);
    expect(
      fixtures.every((shipment) => shipment.createdBy == 'demo-user'),
      isTrue,
    );
  });

  test('stores two comparable bids on LOD-1002 only', () {
    final fixtures = SampleShipmentFixtures.forUser(
      'demo-user',
      now: DateTime.utc(2026, 11, 10),
    );
    final bidShipment = fixtures.singleWhere(
      (shipment) => shipment.reference == 'LOD-1002',
    );

    expect(bidShipment.bids, hasLength(2));
    expect(bidShipment.bids.map((bid) => bid.carrier), [
      'Himalayan Cargo',
      'Swift Transport',
    ]);
    expect(bidShipment.bids.map((bid) => bid.fare), [32000, 29500]);
    expect(bidShipment.bids.map((bid) => bid.rating), [4.6, 4.1]);
    expect(bidShipment.bids.map((bid) => bid.deliveryDays), [2, 3]);
    expect(
      fixtures
          .where((shipment) => shipment.reference != 'LOD-1002')
          .every((shipment) => shipment.bids.isEmpty),
      isTrue,
    );
  });
}
