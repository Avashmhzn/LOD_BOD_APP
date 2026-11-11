import '../entities/shipment_entity.dart';

typedef ShipmentRoutePoint = ({String label, String location});

List<ShipmentRoutePoint> shipmentRoutePoints(ShipmentEntity shipment) {
  final points = <ShipmentRoutePoint>[
    (label: 'Pickup', location: shipment.pickupLocation ?? 'Not provided'),
  ];
  final pickupNumbers = <String, int>{'pickup': 0, 'drop': 0};
  final rawStops = shipment.extraData['intermediateStops'];

  if (rawStops is List) {
    for (final rawStop in rawStops.whereType<Map>()) {
      final location = rawStop['location']?.toString().trim() ?? '';
      if (location.isEmpty) continue;

      final type = rawStop['type']?.toString().toLowerCase() == 'pickup'
          ? 'pickup'
          : 'drop';
      pickupNumbers[type] = pickupNumbers[type]! + 1;
      final label = type == 'pickup'
          ? 'Pickup point ${pickupNumbers[type]}'
          : 'Drop point ${pickupNumbers[type]}';
      points.add((label: label, location: location));
    }
  }

  points.add((
    label: 'Destination',
    location: shipment.deliveryLocation ?? 'Not provided',
  ));
  return points;
}

String shipmentRouteSummary(ShipmentEntity shipment) =>
    shipmentRoutePoints(shipment).map((point) => point.location).join(' → ');
