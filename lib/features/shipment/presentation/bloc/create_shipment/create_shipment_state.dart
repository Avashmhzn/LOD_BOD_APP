import 'package:lodbod_app/features/shipment/domain/entities/shipment_entity.dart';

sealed class CreateShipmentState {
  const CreateShipmentState();
}

final class CreateShipmentInitial extends CreateShipmentState {
  const CreateShipmentInitial();
}

final class CreatingShipment extends CreateShipmentState {
  const CreatingShipment();
}

final class CreateShipmentFailure extends CreateShipmentState {
  const CreateShipmentFailure(this.message);

  final String message;
}

final class CreateShipmentSuccess extends CreateShipmentState {
  const CreateShipmentSuccess({required this.shipment, required this.isDraft});

  final ShipmentEntity shipment;
  final bool isDraft;
}
