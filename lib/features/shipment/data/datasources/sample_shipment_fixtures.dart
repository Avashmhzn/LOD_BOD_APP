
import 'package:lodbod_app/features/shipment/data/models/shipment_model.dart';
import 'package:lodbod_app/features/shipment/domain/entities/shipment_bid_entity.dart';
import 'package:lodbod_app/features/shipment/domain/entities/shipment_status_event.dart';

import 'sample_bid_fixtures.dart';

class SampleShipmentFixtures {
  static List<ShipmentModel> forUser(String userId, {DateTime? now}) {
    final createdAt = now ?? DateTime.now().toUtc();
    final bids = SampleBidFixtures.awaitingBids
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

    return [
      ShipmentModel(
        id: 'demo_${userId}_1001',
        reference: 'LOD-1001',
        pickupLocation: 'Kathmandu',
        deliveryLocation: 'Pokhara',
        cargoDescription: 'Steel pipes',
        cargoCategory: 'Steel',
        weight: 10,
        weightUnit: 'tonne',
        vehicleType: '10 W Open',
        pickupAt: createdAt.subtract(const Duration(days: 1)),
        expectedFare: 18000,
        createdBy: userId,
        status: 'in_transit',
        createdAt: createdAt.subtract(const Duration(days: 3)),
        statusHistory: [
          ShipmentStatusEvent(
            status: 'awaiting_bids',
            at: createdAt.subtract(const Duration(days: 3)),
          ),
          ShipmentStatusEvent(
            status: 'in_transit',
            at: createdAt.subtract(const Duration(days: 1)),
            location: 'Mugling',
          ),
        ],
      ),
      ShipmentModel(
        id: 'demo_${userId}_1002',
        reference: 'LOD-1002',
        pickupLocation: 'Birgunj',
        deliveryLocation: 'Kathmandu',
        cargoDescription: 'Cement',
        cargoCategory: 'Cement',
        weight: 12,
        weightUnit: 'tonne',
        vehicleType: '12 W Open',
        pickupAt: createdAt.add(const Duration(days: 5)),
        createdBy: userId,
        status: 'awaiting_bids',
        bidCount: bids.length,
        createdAt: createdAt.subtract(const Duration(hours: 8)),
        biddingClosesAt: createdAt.add(const Duration(days: 2)),
        bids: bids,
        extraData: const {'assessmentFixture': true},
        statusHistory: [
          ShipmentStatusEvent(
            status: 'awaiting_bids',
            at: createdAt.subtract(const Duration(hours: 8)),
          ),
        ],
      ),
      ShipmentModel(
        id: 'demo_${userId}_1003',
        reference: 'LOD-1003',
        pickupLocation: 'Butwal',
        deliveryLocation: 'Narayanghat',
        cargoDescription: 'Rice sacks',
        cargoCategory: 'Rice sacks',
        weight: 8,
        weightUnit: 'tonne',
        vehicleType: '10 W Closed',
        pickupAt: createdAt.subtract(const Duration(days: 30)),
        expectedFare: 12500,
        createdBy: userId,
        status: 'delivered',
        createdAt: createdAt.subtract(const Duration(days: 33)),
        statusHistory: [
          ShipmentStatusEvent(
            status: 'delivered',
            at: createdAt.subtract(const Duration(days: 29)),
          ),
        ],
      ),
      ShipmentModel(
        id: 'demo_${userId}_1004',
        reference: 'LOD-1004',
        pickupLocation: 'Kathmandu',
        deliveryLocation: 'Biratnagar',
        cargoDescription: 'Furniture',
        cargoCategory: 'Furniture',
        weight: 4,
        weightUnit: 'tonne',
        vehicleType: '10 W Closed',
        pickupAt: createdAt.add(const Duration(days: 6)),
        expectedFare: 24000,
        createdBy: userId,
        status: 'scheduled',
        createdAt: createdAt.subtract(const Duration(days: 1)),
        statusHistory: [
          ShipmentStatusEvent(
            status: 'scheduled',
            at: createdAt.subtract(const Duration(days: 1)),
          ),
        ],
      ),
    ];
  }
}
