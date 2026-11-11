import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/shipment_entity.dart';

abstract class ShipmentRepository {
  Future<Either<Failure, List<ShipmentEntity>>> getShipments();

  Future<Either<Failure, ShipmentEntity>> createShipment(
    ShipmentEntity shipment,
  );

  Future<Either<Failure, ShipmentEntity>> updateShipment(
    ShipmentEntity shipment,
  );

  Future<Either<Failure, ShipmentEntity>> placeBid({
    required String shipmentId,
    required double fare,
    required int deliveryDays,
  });

  Future<Either<Failure, ShipmentEntity>> acceptBid({
    required String shipmentId,
    required String bidId,
  });
}
