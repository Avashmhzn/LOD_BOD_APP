import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/shipment_entity.dart';
import '../repositories/shipment_repository.dart';

class PlaceShipmentBidUseCase {
  const PlaceShipmentBidUseCase(this.repository);

  final ShipmentRepository repository;

  Future<Either<Failure, ShipmentEntity>> call({
    required String shipmentId,
    required double fare,
    required int deliveryDays,
  }) {
    if (fare <= 0 || deliveryDays <= 0) {
      return Future.value(
        const Left(ValidationFailure('Enter a valid fare and delivery time.')),
      );
    }
    return repository.placeBid(
      shipmentId: shipmentId,
      fare: fare,
      deliveryDays: deliveryDays,
    );
  }
}
