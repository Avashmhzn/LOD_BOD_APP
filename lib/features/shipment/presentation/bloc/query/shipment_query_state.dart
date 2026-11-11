import 'package:lodbod_app/features/shipment/domain/entities/shipment_entity.dart';

enum ShipmentQueryStatus { initial, loading, success, failure }

class ShipmentQueryState {
  const ShipmentQueryState({
    this.status = ShipmentQueryStatus.initial,
    this.shipments = const [],
    this.message,
  });

  final ShipmentQueryStatus status;
  final List<ShipmentEntity> shipments;
  final String? message;
}
