import 'package:flutter_test/flutter_test.dart';
import 'package:lodbod_app/features/shipment/data/datasources/sample_bid_fixtures.dart';
import 'package:lodbod_app/features/shipment/domain/entities/shipment_bid_entity.dart';

void main() {
  test('provides two distinct assessment bids for awaiting-bids shipments', () {
    final bids = SampleBidFixtures.forShipment(
      status: 'awaiting_bids',
      savedBids: const [],
    );

    expect(bids, hasLength(2));
    expect(bids.map((bid) => bid.carrier), [
      'Himalayan Cargo',
      'Swift Transport',
    ]);
    expect(bids.map((bid) => bid.fare), [32000, 29500]);
    expect(bids.map((bid) => bid.rating), [4.6, 4.1]);
    expect(bids.map((bid) => bid.deliveryDays), [2, 3]);
  });

  test('applies bids regardless of route/reference when awaiting bids', () {
    expect(
      SampleBidFixtures.forShipment(status: 'pending', savedBids: const []),
      hasLength(2),
    );
    expect(
      SampleBidFixtures.forShipment(status: 'scheduled', savedBids: const []),
      isEmpty,
    );
  });

  test('uses stored bids instead of assessment examples', () {
    const stored = [
      ShipmentBidEntity(
        id: 'real-1',
        carrier: 'Stored Carrier',
        fare: 40000,
        rating: 4.8,
        deliveryDays: 1,
      ),
    ];

    expect(
      SampleBidFixtures.forShipment(status: 'awaiting bids', savedBids: stored),
      same(stored),
    );
  });
}
