import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:lodbod_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:lodbod_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:lodbod_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:lodbod_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:lodbod_app/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:lodbod_app/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:lodbod_app/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:lodbod_app/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:lodbod_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lodbod_app/features/account/presentation/bloc/account_profile_bloc.dart';
import 'package:lodbod_app/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:lodbod_app/features/shipment/data/datasources/shipment_local_datasource.dart';
import 'package:lodbod_app/features/shipment/data/datasources/shipment_remote_datasource.dart';
import 'package:lodbod_app/features/shipment/data/repositories/shipment_repository_impl.dart';
import 'package:lodbod_app/features/shipment/domain/repositories/shipment_repository.dart';
import 'package:lodbod_app/features/shipment/domain/usecases/accept_shipment_bid_usecase.dart';
import 'package:lodbod_app/features/shipment/domain/usecases/create_shipment_usecase.dart';
import 'package:lodbod_app/features/shipment/domain/usecases/get_shipments_usecase.dart';
import 'package:lodbod_app/features/shipment/domain/usecases/place_shipment_bid_usecase.dart';
import 'package:lodbod_app/features/shipment/presentation/bloc/bid/bid_bloc.dart';
import 'package:lodbod_app/features/shipment/presentation/bloc/create_shipment/create_shipment_bloc.dart';
import 'package:lodbod_app/features/shipment/presentation/bloc/query/shipment_query_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features -Auth
  sl.registerFactory(
    () => AuthBloc(
      signIn: sl(),
      signUp: sl(),
      signOut: sl(),
      getCurrentUser: sl(),
      verifyOtp: sl(),
    ),
  );
  sl.registerFactory(
    () =>
        DashboardBloc(firebaseAuth: sl(), firestore: sl(), getShipments: sl()),
  );
  sl.registerFactory(
    () => AccountProfileBloc(
      firebaseAuth: sl(),
      firestore: sl(),
      authRemoteDataSource: sl(),
    ),
  );

  // Use case
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), firestore: sl()),
  );

  // Features - Shipment
  sl.registerFactory(
    () => BidBloc(placeShipmentBid: sl(), acceptShipmentBid: sl()),
  );
  sl.registerFactory(
    () => CreateShipmentBloc(createShipment: sl(), getShipments: sl()),
  );
  sl.registerFactory(() => ShipmentQueryBloc(getShipments: sl()));
  sl.registerLazySingleton(() => CreateShipmentUseCase(sl()));
  sl.registerLazySingleton(() => GetShipmentsUseCase(sl()));
  sl.registerLazySingleton(() => AcceptShipmentBidUseCase(sl()));
  sl.registerLazySingleton(() => PlaceShipmentBidUseCase(sl()));
  sl.registerLazySingleton<ShipmentRepository>(
    () => ShipmentRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      connectivity: sl(),
    ),
  );
  sl.registerLazySingleton<ShipmentRemoteDataSource>(
    () => ShipmentRemoteDataSourceImpl(firestore: sl(), functions: sl()),
  );
  sl.registerLazySingleton<ShipmentLocalDataSource>(
    () => ShipmentLocalDataSourceImpl(),
  );

  // External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseFunctions.instance);
  sl.registerLazySingleton(() => Connectivity());
}
