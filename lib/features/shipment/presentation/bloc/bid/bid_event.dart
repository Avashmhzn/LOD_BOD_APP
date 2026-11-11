import 'package:lodbod_app/features/shipment/domain/entities/shipment_bid_entity.dart';
import 'package:lodbod_app/features/shipment/domain/entities/shipment_entity.dart';

sealed class BidEvent {
  const BidEvent();
}

final class SubmitBid extends BidEvent {
  const SubmitBid({
    required this.shipmentId,
    required this.fare,
    required this.deliveryDays,
  });

  final String shipmentId;
  final double fare;
  final int deliveryDays;
}

final class AcceptBid extends BidEvent {
  const AcceptBid({
    required this.shipment,
    required this.selectedBid,
    required this.availableBids,
  });

  final ShipmentEntity shipment;
  final ShipmentBidEntity selectedBid;
  final List<ShipmentBidEntity> availableBids;
}
