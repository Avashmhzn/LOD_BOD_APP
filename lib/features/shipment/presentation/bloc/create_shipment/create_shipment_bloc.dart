import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lodbod_app/features/shipment/domain/usecases/create_shipment_usecase.dart';
import 'package:lodbod_app/features/shipment/domain/usecases/get_shipments_usecase.dart';

import 'create_shipment_event.dart';
import 'create_shipment_state.dart';

class CreateShipmentBloc
    extends Bloc<CreateShipmentEvent, CreateShipmentState> {
  CreateShipmentBloc({required this.createShipment, required this.getShipments})
    : super(const CreateShipmentInitial()) {
    on<SubmitShipment>(_onSubmitShipment);
  }

  final CreateShipmentUseCase createShipment;
  final GetShipmentsUseCase getShipments;

  static const _qualifyingStatuses = {
    'open',
    'pending',
    'awaiting bids',
    'scheduled',
    'confirmed',
    'in transit',
    'active',
    'in progress',
  };

  Future<void> _onSubmitShipment(
    SubmitShipment event,
    Emitter<CreateShipmentState> emit,
  ) async {
    emit(const CreatingShipment());

    if (!event.isDraft) {
      final shipmentsResult = await getShipments();
      final shipments = shipmentsResult.fold((failure) {
        emit(CreateShipmentFailure(failure.message));
        return null;
      }, (items) => items);
      if (shipments == null || emit.isDone) return;

      final requestCount = shipments.where((shipment) {
        final status = shipment.status.toLowerCase().replaceAll('_', ' ');
        return _qualifyingStatuses.contains(status);
      }).length;
      if (requestCount >= 3) {
        emit(
          const CreateShipmentFailure(
            'You have reached the mobile request limit of 3. Please use the LODBOD web platform to create additional requests.',
          ),
        );
        return;
      }
    }

    final result = await createShipment(event.shipment);
    result.fold(
      (failure) => emit(CreateShipmentFailure(failure.message)),
      (shipment) => emit(
        CreateShipmentSuccess(shipment: shipment, isDraft: event.isDraft),
      ),
    );
  }
}
