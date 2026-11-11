import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lodbod_app/features/shipment/domain/usecases/get_shipments_usecase.dart';

import 'shipment_query_event.dart';
import 'shipment_query_state.dart';

class ShipmentQueryBloc extends Bloc<ShipmentQueryEvent, ShipmentQueryState> {
  ShipmentQueryBloc({required this.getShipments})
    : super(const ShipmentQueryState()) {
    on<LoadShipments>(_onLoadShipments);
  }

  final GetShipmentsUseCase getShipments;

  Future<void> _onLoadShipments(
    LoadShipments event,
    Emitter<ShipmentQueryState> emit,
  ) async {
    emit(const ShipmentQueryState(status: ShipmentQueryStatus.loading));
    final result = await getShipments();
    result.fold(
      (failure) => emit(
        ShipmentQueryState(
          status: ShipmentQueryStatus.failure,
          message: failure.message,
        ),
      ),
      (shipments) => emit(
        ShipmentQueryState(
          status: ShipmentQueryStatus.success,
          shipments: shipments,
        ),
      ),
    );
  }
}
