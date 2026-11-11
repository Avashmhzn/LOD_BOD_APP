import 'package:lodbod_app/features/shipment/domain/entities/shipment_entity.dart';

sealed class CreateShipmentEvent {
  const CreateShipmentEvent();
}

final class SubmitShipment extends CreateShipmentEvent {
  const SubmitShipment({required this.shipment, required this.isDraft});

  final ShipmentEntity shipment;
  final bool isDraft;
}
