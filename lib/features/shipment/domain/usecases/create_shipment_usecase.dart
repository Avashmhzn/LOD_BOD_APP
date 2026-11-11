import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/shipment_entity.dart';
import '../repositories/shipment_repository.dart';

class CreateShipmentUseCase {
  final ShipmentRepository repository;

  CreateShipmentUseCase(this.repository);

  Future<Either<Failure, ShipmentEntity>> call(ShipmentEntity shipment) {
    return repository.createShipment(shipment);
  }
}
