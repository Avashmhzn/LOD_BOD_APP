import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lodbod_app/core/utils/logger.dart';
import 'package:lodbod_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:lodbod_app/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:lodbod_app/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:lodbod_app/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:lodbod_app/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signIn;
  final SignUpUseCase signUp;
  final SignOutUseCase signOut;
  final GetCurrentUserUseCase getCurrentUser;
  final VerifyOtpUseCase verifyOtp;

  AuthBloc({
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.getCurrentUser,
    required this.verifyOtp,
  }) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignInEvent>(_onSignIn);
    on<SignUpEvent>(_onSignUp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<ResendOtpEvent>(_onResendOtp);
    on<SignOutEvent>(_onSignOut);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await getCurrentUser();

    result.fold(
      (failure) {
        AppLogger.info('No user authenticated');
        emit(Unauthenticated());
      },
      (user) {
        if (user != null) {
          AppLogger.info('User authenticated: ${user.uid}');
          emit(Authenticated(user));
        } else {
          AppLogger.info('User not authenticated');
          emit(Unauthenticated());
        }
      },
    );
  }

  Future<void> _onSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await signIn(
      SignInParams(
        identifier: event.identifier,
        password: event.password,
        isPhone: event.isPhone,
      ),
    );

    result.fold(
      (failure) {
        emit(AuthError(failure.message));
        emit(Unauthenticated());
      },
      (user) {
        AppLogger.info('Sign in successful');
        emit(Authenticated(user));
      },
    );
  }

  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await signUp(
      SignUpParams(
        email: event.email,
        password: event.password,
        phoneNumber: event.phoneNumber,
        displayName: event.displayName,
        companyName: event.companyName,
        role: event.role,
      ),
    );

    await result.fold<Future<void>>(
      (failure) async {
        AppLogger.error('Sign up failed: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (user) async {
        AppLogger.info('Sign up successful, forcing sign out to go to login');
        await signOut();
        if (!emit.isDone) {
          emit(Unauthenticated());
        }
      },
    );
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await verifyOtp(
      VerifyOtpParams(email: event.email, otp: event.otp),
    );

    result.fold(
      (failure) {
        AppLogger.error('OTP verification failed: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (isVerified) {
        if (isVerified) {
          AppLogger.info('OTP verified successfully');
          add(CheckAuthStatusEvent());
        } else {
          AppLogger.error('OTP verification failed: Invalid code');
          emit(AuthError('Invalid OTP code'));
        }
      },
    );
  }

  Future<void> _onResendOtp(
    ResendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {

    AppLogger.info('Resending OTP to ${event.email}');
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await signOut();

    result.fold(
      (failure) {
        AppLogger.error('Sign out failed: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (_) {
        AppLogger.info('Sign out successful');
        emit(Unauthenticated());
      },
    );
  }
}
