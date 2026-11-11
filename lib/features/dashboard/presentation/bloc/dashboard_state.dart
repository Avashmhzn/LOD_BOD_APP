import 'package:lodbod_app/features/shipment/domain/entities/shipment_entity.dart';

enum DashboardStatus { initial, loading, loaded, failure }

class DashboardState {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.role,
    this.shipments = const [],
    this.message,
  });

  final DashboardStatus status;
  final String? role;
  final List<ShipmentEntity> shipments;
  final String? message;
}
