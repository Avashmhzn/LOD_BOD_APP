import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lodbod_app/core/error/exceptions.dart';
import 'package:lodbod_app/features/auth/data/datasources/auth_remote_datasource.dart';

import 'account_profile_event.dart';
import 'account_profile_state.dart';

class AccountProfileBloc
    extends Bloc<AccountProfileEvent, AccountProfileState> {
  AccountProfileBloc({
    required this.firebaseAuth,
    required this.firestore,
    required this.authRemoteDataSource,
  }) : super(const AccountProfileState()) {
    on<LoadAccountProfile>(_onLoadAccountProfile);
    on<SaveAccountProfile>(_onSaveAccountProfile);
    on<SendAccountPasswordReset>(_onSendPasswordReset);
    on<SignOutAccount>(_onSignOut);
    on<DeleteAccount>(_onDeleteAccount);
  }

  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final AuthRemoteDataSource authRemoteDataSource;

  Future<void> _onLoadAccountProfile(
    LoadAccountProfile event,
    Emitter<AccountProfileState> emit,
  ) async {
    emit(const AccountProfileState(status: AccountProfileStatus.loading));
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        emit(const AccountProfileState(status: AccountProfileStatus.loaded));
        return;
      }
      final snapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 10));
      emit(
        AccountProfileState(
          status: AccountProfileStatus.loaded,
          profile: snapshot.data() ?? const {},
        ),
      );
    } catch (error) {
      emit(
        AccountProfileState(
          status: AccountProfileStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }

  Future<void> _onSaveAccountProfile(
    SaveAccountProfile event,
    Emitter<AccountProfileState> emit,
  ) async {
    emit(
      AccountProfileState(
        status: AccountProfileStatus.actionLoading,
        profile: state.profile,
        action: AccountProfileAction.save,
      ),
    );
    try {
      await authRemoteDataSource.updateUserProfile(
        displayName: event.displayName,
        companyName: event.companyName,
      );
      emit(
        AccountProfileState(
          status: AccountProfileStatus.actionSuccess,
          profile: state.profile,
          action: AccountProfileAction.save,
        ),
      );
    } catch (error) {
      _emitActionFailure(emit, AccountProfileAction.save, error);
    }
  }

  Future<void> _onSendPasswordReset(
    SendAccountPasswordReset event,
    Emitter<AccountProfileState> emit,
  ) async {
    emit(
      AccountProfileState(
        status: AccountProfileStatus.actionLoading,
        profile: state.profile,
        action: AccountProfileAction.passwordReset,
        email: event.email,
      ),
    );
    try {
      await authRemoteDataSource.sendPasswordResetEmail(email: event.email);
      emit(
        AccountProfileState(
          status: AccountProfileStatus.actionSuccess,
          profile: state.profile,
          action: AccountProfileAction.passwordReset,
          email: event.email,
        ),
      );
    } catch (error) {
      _emitActionFailure(
        emit,
        AccountProfileAction.passwordReset,
        error,
        email: event.email,
      );
    }
  }

  Future<void> _onSignOut(
    SignOutAccount event,
    Emitter<AccountProfileState> emit,
  ) async {
    await _runAccountAction(emit, AccountProfileAction.signOut, () async {
      await authRemoteDataSource.signOut();
    });
  }

  Future<void> _onDeleteAccount(
    DeleteAccount event,
    Emitter<AccountProfileState> emit,
  ) async {
    await _runAccountAction(emit, AccountProfileAction.delete, () async {
      await authRemoteDataSource.deleteAccount();
    });
  }

  Future<void> _runAccountAction(
    Emitter<AccountProfileState> emit,
    AccountProfileAction action,
    Future<void> Function() operation,
  ) async {
    emit(
      AccountProfileState(
        status: AccountProfileStatus.actionLoading,
        profile: state.profile,
        action: action,
      ),
    );
    try {
      await operation();
      emit(
        AccountProfileState(
          status: AccountProfileStatus.actionSuccess,
          profile: state.profile,
          action: action,
        ),
      );
    } catch (error) {
      _emitActionFailure(emit, action, error);
    }
  }

  void _emitActionFailure(
    Emitter<AccountProfileState> emit,
    AccountProfileAction action,
    Object error, {
    String? email,
  }) {
    emit(
      AccountProfileState(
        status: AccountProfileStatus.actionFailure,
        profile: state.profile,
        action: action,
        email: email,
        message: error is AuthException ? error.message : error.toString(),
      ),
    );
  }
}
