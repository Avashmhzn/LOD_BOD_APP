import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lodbod_app/features/shipment/domain/entities/shipment_entity.dart';
import 'package:lodbod_app/features/shipment/domain/usecases/get_shipments_usecase.dart';

import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({
    required this.firebaseAuth,
    required this.firestore,
    required this.getShipments,
  }) : super(const DashboardState()) {
    on<LoadDashboard>(_onLoadDashboard);
  }

  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GetShipmentsUseCase getShipments;

  DateTime _createdAt(ShipmentEntity shipment) =>
      shipment.createdAt ?? DateTime(2000);

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardState(status: DashboardStatus.loading));
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        emit(
          const DashboardState(
            status: DashboardStatus.loaded,
            role: 'signed_out',
          ),
        );
        return;
      }

      final profile = await firestore.collection('users').doc(user.uid).get();
      final role = profile.exists
          ? (profile.data()?['role'] as String? ?? 'shipper')
          : 'unassigned';
      if (role != 'shipper') {
        emit(DashboardState(status: DashboardStatus.loaded, role: role));
        return;
      }

      final result = await getShipments();
      result.fold(
        (failure) => emit(
          DashboardState(
            status: DashboardStatus.failure,
            role: role,
            message: failure.message,
          ),
        ),
        (items) {
          final sorted = [...items]
            ..sort((a, b) => _createdAt(b).compareTo(_createdAt(a)));
          emit(
            DashboardState(
              status: DashboardStatus.loaded,
              role: role,
              shipments: sorted,
            ),
          );
        },
      );
    } catch (error) {
      emit(
        DashboardState(
          status: DashboardStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }
}
