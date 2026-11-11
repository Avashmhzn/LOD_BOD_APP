import 'package:flutter_test/flutter_test.dart';
import 'package:lodbod_app/features/shipment/domain/entities/shipment_entity.dart';
import 'package:lodbod_app/features/shipment/domain/utils/shipment_route.dart';

void main() {
  test('shows each intermediate pickup in route order', () {
    final shipment = ShipmentEntity(
      id: 'shipment-1',
      pickupLocation: 'Kathmandu',
      deliveryLocation: 'Pokhara',
      extraData: {
        'intermediateStops': [
          {'type': 'pickup', 'location': 'Bhaktapur'},
          {'type': 'pickup', 'location': 'Banepa'},
        ],
      },
    );

    expect(shipmentRoutePoints(shipment), [
      (label: 'Pickup', location: 'Kathmandu'),
      (label: 'Pickup point 1', location: 'Bhaktapur'),
      (label: 'Pickup point 2', location: 'Banepa'),
      (label: 'Destination', location: 'Pokhara'),
    ]);
    expect(
      shipmentRouteSummary(shipment),
      'Kathmandu → Bhaktapur → Banepa → Pokhara',
    );
  });

  test('labels and preserves both pickup and drop intermediate stops', () {
    final shipment = ShipmentEntity(
      id: 'shipment-2',
      pickupLocation: 'Birgunj',
      deliveryLocation: 'Kathmandu',
      extraData: {
        'intermediateStops': [
          {'type': 'pickup', 'location': 'Hetauda'},
          {'type': 'drop', 'location': 'Naubise'},
        ],
      },
    );

    expect(shipmentRoutePoints(shipment).map((point) => point.label), [
      'Pickup',
      'Pickup point 1',
      'Drop point 1',
      'Destination',
    ]);
  });
}
