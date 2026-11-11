import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lodbod_app/features/shipment/domain/usecases/accept_shipment_bid_usecase.dart';
import 'package:lodbod_app/features/shipment/domain/usecases/place_shipment_bid_usecase.dart';

import 'bid_event.dart';
import 'bid_state.dart';

class BidBloc extends Bloc<BidEvent, BidState> {
  BidBloc({required this.placeShipmentBid, required this.acceptShipmentBid})
    : super(const BidInitial()) {
    on<SubmitBid>(_onSubmitBid);
    on<AcceptBid>(_onAcceptBid);
  }

  final PlaceShipmentBidUseCase placeShipmentBid;
  final AcceptShipmentBidUseCase acceptShipmentBid;

  Future<void> _onSubmitBid(SubmitBid event, Emitter<BidState> emit) async {
    emit(const BidSubmitting());
    final result = await placeShipmentBid(
      shipmentId: event.shipmentId,
      fare: event.fare,
      deliveryDays: event.deliveryDays,
    );
    result.fold(
      (failure) => emit(BidSubmissionFailure(failure.message)),
      (_) => emit(const BidSubmissionSuccess()),
    );
  }

  Future<void> _onAcceptBid(AcceptBid event, Emitter<BidState> emit) async {
    emit(const BidSubmitting());
    final result = await acceptShipmentBid(
      shipment: event.shipment,
      selectedBid: event.selectedBid,
      availableBids: event.availableBids,
    );
    result.fold(
      (failure) => emit(BidSubmissionFailure(failure.message)),
      (shipment) => emit(BidAcceptanceSuccess(shipment)),
    );
  }
}
