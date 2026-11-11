import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:lodbod_app/core/error/exceptions.dart';
import 'package:lodbod_app/core/error/failures.dart';
import 'package:lodbod_app/core/utils/logger.dart';
import 'package:lodbod_app/features/shipment/data/datasources/shipment_local_datasource.dart';
import 'package:lodbod_app/features/shipment/data/datasources/shipment_remote_datasource.dart';
import 'package:lodbod_app/features/shipment/data/models/shipment_model.dart';
import 'package:lodbod_app/features/shipment/domain/entities/shipment_entity.dart';
import 'package:lodbod_app/features/shipment/domain/repositories/shipment_repository.dart';

class ShipmentRepositoryImpl implements ShipmentRepository {
  final ShipmentRemoteDataSource remoteDataSource;
  final ShipmentLocalDataSource localDataSource;
  final Connectivity connectivity;

  ShipmentRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
  });

  @override
  Future<Either<Failure, List<ShipmentEntity>>> getShipments() async {
    try {
      // Always try cache first (instant response)
      final cachedShipments = await localDataSource.getCachedShipments();

      // Check network
      final connectivityResult = await connectivity.checkConnectivity();
      final isOnline = !connectivityResult.contains(ConnectivityResult.none);

      if (isOnline) {
        try {
          // Fetch fresh data in background
          final remoteShipments = await remoteDataSource.getShipments();

          // Update cache
          await localDataSource.cacheShipments(remoteShipments);

          AppLogger.info(
            'Fetched ${remoteShipments.length} shipments from network',
          );
          return Right(remoteShipments);
        } catch (e) {
          AppLogger.warning('Network fetch failed, using cache', e);
          // Network failed but we have cache - return it
          if (cachedShipments.isNotEmpty) {
            return Right(cachedShipments);
          }
          rethrow;
        }
      } else {
        // Offline - return cache
        AppLogger.info('Offline mode: using cached shipments');
        if (cachedShipments.isEmpty) {
          return const Left(NetworkFailure('No internet and no cached data'));
        }
        return Right(cachedShipments);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      AppLogger.error('Unexpected error in getShipments', e);
      return const Left(ServerFailure('Failed to fetch shipments'));
    }
  }

  @override
  Future<Either<Failure, ShipmentEntity>> createShipment(
    ShipmentEntity shipment,
  ) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      final isOnline = !connectivityResult.contains(ConnectivityResult.none);

      if (!isOnline) {
        return const Left(
          NetworkFailure('Connect to the internet to save this shipment'),
        );
      }

      final model = ShipmentModel.fromEntity(shipment);
      final created = await remoteDataSource.createShipment(model);
      await localDataSource.cacheShipment(created);
      return Right(created);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to create shipment'));
    }
  }

  @override
  Future<Either<Failure, ShipmentEntity>> updateShipment(
    ShipmentEntity shipment,
  ) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(
          NetworkFailure('Connect to the internet to update this shipment'),
        );
      }

      final updated = await remoteDataSource.updateShipment(
        ShipmentModel.fromEntity(shipment),
      );
      await localDataSource.cacheShipment(updated);
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update shipment'));
    }
  }

  @override
  Future<Either<Failure, ShipmentEntity>> placeBid({
    required String shipmentId,
    required double fare,
    required int deliveryDays,
  }) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('Connect to place a bid'));
      }
      final updated = await remoteDataSource.placeBid(
        shipmentId: shipmentId,
        fare: fare,
        deliveryDays: deliveryDays,
      );
      await localDataSource.cacheShipment(updated);
      return Right(updated);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (error) {
      return const Left(ServerFailure('Failed to place bid'));
    }
  }

  @override
  Future<Either<Failure, ShipmentEntity>> acceptBid({
    required String shipmentId,
    required String bidId,
  }) async {
    try {
      final updated = await remoteDataSource.acceptBid(
        shipmentId: shipmentId,
        bidId: bidId,
      );
      await localDataSource.cacheShipment(updated);
      return Right(updated);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (error) {
      return const Left(ServerFailure('Failed to accept bid'));
    }
  }
}
