import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lodbod_app/features/shipment/data/models/shipment_model.dart';
import 'package:lodbod_app/features/shipment/domain/entities/shipment_bid_entity.dart';
import 'package:lodbod_app/features/shipment/domain/entities/shipment_entity.dart';
import 'package:lodbod_app/features/shipment/domain/entities/shipment_status_event.dart';

void main() {
  group('ShipmentModel', () {
    test('parses Firestore timestamps and legacy date fields', () {
      final pickupAt = DateTime.utc(2026, 11, 14, 8);
      final closeAt = DateTime.utc(2026, 11, 12, 8);
      final createdAt = DateTime.utc(2026, 11, 9, 8);

      final shipment = ShipmentModel.fromJson({
        'id': 'shipment-1',
        'reference': 'LOD-1002',
        'pickupDate': Timestamp.fromDate(pickupAt),
        'bidEndsAt': Timestamp.fromDate(closeAt),
        'createdAt': Timestamp.fromDate(createdAt),
        'status': 'awaiting_bids',
        'bidCount': 2,
        'bids': [
          {
            'id': 'carrier-1',
            'carrier': 'Himalayan Cargo',
            'fare': 32000,
            'rating': 4.6,
            'deliveryDays': 2,
          },
        ],
        'statusHistory': [
          {'status': 'awaiting_bids', 'at': Timestamp.fromDate(createdAt)},
        ],
        'externalMetadata': {'source': 'assessment'},
      });

      expect(shipment.id, 'shipment-1');
      expect(shipment.pickupAt!.isAtSameMomentAs(pickupAt), isTrue);
      expect(shipment.biddingClosesAt!.isAtSameMomentAs(closeAt), isTrue);
      expect(shipment.bids.single.fare, 32000);
      expect(
        shipment.statusHistory.single.at!.isAtSameMomentAs(createdAt),
        isTrue,
      );
      expect(shipment.extraData['externalMetadata'], {'source': 'assessment'});
    });

    test('serializes typed fields and retains unmodeled fields', () {
      final shipment = ShipmentModel.fromEntity(
        ShipmentEntity(
          id: 'shipment-2',
          reference: 'LOD-1003',
          status: 'scheduled',
          expectedFare: 29500,
          bids: const [
            ShipmentBidEntity(
              id: 'carrier-2',
              carrier: 'Swift Transport',
              fare: 29500,
              rating: 4.1,
              deliveryDays: 3,
              status: 'accepted',
            ),
          ],
          statusHistory: [
            ShipmentStatusEvent(
              status: 'scheduled',
              at: DateTime.utc(2026, 11, 9),
            ),
          ],
          extraData: const {'externalMetadata': 'retained'},
        ),
      );

      final json = shipment.toJson();

      expect(json['reference'], 'LOD-1003');
      expect(json['expectedFare'], 29500);
      expect((json['bids'] as List).single['status'], 'accepted');
      expect((json['statusHistory'] as List).single['status'], 'scheduled');
      expect(json['externalMetadata'], 'retained');
    });
  });
}
