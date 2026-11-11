import 'package:lodbod_app/features/shipment/domain/entities/shipment_bid_entity.dart';

class SampleBidFixtures {
  static const awaitingBids = [
    {
      'id': 'himalayan-cargo',
      'carrier': 'Himalayan Cargo',
      'fare': 32000,
      'rating': 4.6,
      'deliveryDays': 2,
    },
    {
      'id': 'swift-transport',
      'carrier': 'Swift Transport',
      'fare': 29500,
      'rating': 4.1,
      'deliveryDays': 3,
    },
  ];

  static List<ShipmentBidEntity> get assessmentBids => awaitingBids
      .map(
        (bid) => ShipmentBidEntity(
          id: bid['id'].toString(),
          carrier: bid['carrier'].toString(),
          fare: (bid['fare'] as num).toDouble(),
          rating: (bid['rating'] as num).toDouble(),
          deliveryDays: bid['deliveryDays'] as int,
        ),
      )
      .toList();

  static List<ShipmentBidEntity> forShipment({
    required String status,
    required List<ShipmentBidEntity> savedBids,
  }) {
    if (savedBids.isNotEmpty) return savedBids;
    final normalizedStatus = status.toLowerCase().replaceAll('_', ' ');
    if (normalizedStatus != 'pending' && normalizedStatus != 'awaiting bids') {
      return const [];
    }
    return assessmentBids;
  }
}
