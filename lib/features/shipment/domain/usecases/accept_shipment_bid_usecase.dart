import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/shipment_bid_entity.dart';
import '../entities/shipment_entity.dart';
import '../repositories/shipment_repository.dart';

class AcceptShipmentBidUseCase {
  const AcceptShipmentBidUseCase(this.repository);

  final ShipmentRepository repository;

  Future<Either<Failure, ShipmentEntity>> call({
    required ShipmentEntity shipment,
    required ShipmentBidEntity selectedBid,
    required List<ShipmentBidEntity> availableBids,
  }) {
    final isAvailableBid = availableBids.any((bid) => bid.id == selectedBid.id);
    if (!isAvailableBid) {
      return Future.value(
        const Left(ValidationFailure('This bid is no longer available.')),
      );
    }

    return repository.acceptBid(shipmentId: shipment.id, bidId: selectedBid.id);
  }
}
