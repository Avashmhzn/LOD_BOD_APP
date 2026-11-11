sealed class ShipmentQueryEvent {
  const ShipmentQueryEvent();
}

final class LoadShipments extends ShipmentQueryEvent {
  const LoadShipments();
}
