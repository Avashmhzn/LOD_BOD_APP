import 'package:lodbod_app/features/shipment/domain/entities/shipment_entity.dart';

sealed class BidState {
  const BidState();
}

final class BidInitial extends BidState {
  const BidInitial();
}

final class BidSubmitting extends BidState {
  const BidSubmitting();
}

final class BidSubmissionFailure extends BidState {
  const BidSubmissionFailure(this.message);

  final String message;
}

final class BidSubmissionSuccess extends BidState {
  const BidSubmissionSuccess();
}

final class BidAcceptanceSuccess extends BidState {
  const BidAcceptanceSuccess(this.shipment);

  final ShipmentEntity shipment;
}
