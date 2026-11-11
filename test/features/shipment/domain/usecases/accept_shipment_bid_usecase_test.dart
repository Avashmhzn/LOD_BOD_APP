import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lodbod_app/core/error/failures.dart';
import 'package:lodbod_app/features/shipment/domain/entities/shipment_bid_entity.dart';
import 'package:lodbod_app/features/shipment/domain/entities/shipment_entity.dart';
import 'package:lodbod_app/features/shipment/domain/repositories/shipment_repository.dart';
import 'package:lodbod_app/features/shipment/domain/usecases/accept_shipment_bid_usecase.dart';

void main() {
  late _RecordingShipmentRepository repository;
  late AcceptShipmentBidUseCase useCase;
  late ShipmentEntity shipment;
  late ShipmentBidEntity selectedBid;
  late ShipmentBidEntity otherBid;

  setUp(() {
    repository = _RecordingShipmentRepository();
    useCase = AcceptShipmentBidUseCase(repository);
    selectedBid = const ShipmentBidEntity(
      id: 'carrier-1',
      carrier: 'Himalayan Cargo',
      fare: 32000,
      rating: 4.6,
      deliveryDays: 2,
    );
    otherBid = const ShipmentBidEntity(
      id: 'carrier-2',
      carrier: 'Swift Transport',
      fare: 29500,
      rating: 4.1,
      deliveryDays: 3,
    );
    shipment = ShipmentEntity(
      id: 'shipment-1',
      status: 'awaiting_bids',
      bids: [selectedBid, otherBid],
    );
  });

  test('sends the selected bid to the trusted acceptance operation', () async {
    final result = await useCase(
      shipment: shipment,
      selectedBid: selectedBid,
      availableBids: [selectedBid, otherBid],
    );

    expect(result.isRight(), isTrue);
    expect(repository.acceptedShipmentId, 'shipment-1');
    expect(repository.acceptedBidId, selectedBid.id);
  });

  test('rejects a bid not present in the available bids', () async {
    final result = await useCase(
      shipment: shipment,
      selectedBid: selectedBid,
      availableBids: [otherBid],
    );

    expect(result.isLeft(), isTrue);
    expect(repository.acceptedShipmentId, isNull);
  });

  test(
    'sends a displayed assessment bid to the repository for validation',
    () async {
      final demoBid = const ShipmentBidEntity(
        id: 'demo-carrier',
        carrier: 'Demo Carrier',
        fare: 25000,
        rating: 4.5,
        deliveryDays: 2,
      );

      final result = await useCase(
        shipment: ShipmentEntity(id: 'shipment-1', bids: const []),
        selectedBid: demoBid,
        availableBids: [demoBid],
      );

      expect(result.isRight(), isTrue);
      expect(repository.acceptedShipmentId, 'shipment-1');
      expect(repository.acceptedBidId, demoBid.id);
    },
  );
}

class _RecordingShipmentRepository implements ShipmentRepository {
  ShipmentEntity? updatedShipment;
  String? acceptedShipmentId;
  String? acceptedBidId;

  @override
  Future<Either<Failure, List<ShipmentEntity>>> getShipments() async =>
      const Right([]);

  @override
  Future<Either<Failure, ShipmentEntity>> createShipment(
    ShipmentEntity shipment,
  ) async => Right(shipment);

  @override
  Future<Either<Failure, ShipmentEntity>> updateShipment(
    ShipmentEntity shipment,
  ) async {
    updatedShipment = shipment;
    return Right(shipment);
  }

  @override
  Future<Either<Failure, ShipmentEntity>> placeBid({
    required String shipmentId,
    required double fare,
    required int deliveryDays,
  }) async => Right(ShipmentEntity(id: shipmentId));

  @override
  Future<Either<Failure, ShipmentEntity>> acceptBid({
    required String shipmentId,
    required String bidId,
  }) async {
    acceptedShipmentId = shipmentId;
    acceptedBidId = bidId;
    return Right(ShipmentEntity(id: shipmentId));
  }
}
