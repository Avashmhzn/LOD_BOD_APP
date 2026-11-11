import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/shipment_entity.dart';
import '../repositories/shipment_repository.dart';

class GetShipmentsUseCase {
  const GetShipmentsUseCase(this.repository);

  final ShipmentRepository repository;

  Future<Either<Failure, List<ShipmentEntity>>> call() =>
      repository.getShipments();
}
