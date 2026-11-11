import 'package:dartz/dartz.dart';
import 'package:lodbod_app/core/error/exceptions.dart';
import 'package:lodbod_app/core/error/failures.dart';
import 'package:lodbod_app/core/utils/logger.dart';
import 'package:lodbod_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:lodbod_app/features/auth/domain/entities/user_entity.dart';
import 'package:lodbod_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> signInWithIdentifierAndPassword({
    required String identifier,
    required String password,
    required bool isPhone,
  }) async {
    try {
      final user = await remoteDataSource.signInWithIdentifierAndPassword(
        identifier: identifier,
        password: password,
        isPhone: isPhone,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network exception in repository', e);
      return Left(NetworkFailure(e.message));
    } catch (e) {
      AppLogger.error('Unexpected exception in repository', e);
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String phoneNumber,
    String? displayName,
    String? companyName,
    String role = 'shipper',
  }) async {
    try {
      final user = await remoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        displayName: displayName,
        companyName: companyName,
        role: role,
      );
      return Right(user);
    } on AuthException catch (e) {
      AppLogger.error('Auth exception in repository', e);
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network exception in repository', e);
      return Left(NetworkFailure(e.message));
    } catch (e) {
      AppLogger.error('Unexpected exception in repository', e);
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to sign out'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get current user'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to send password reset email'));
    }
  }

  @override
  Future<Either<Failure, void>> sendCustomOtp({required String email}) async {
    try {
      await remoteDataSource.sendCustomOtp(email: email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to send OTP'));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final isVerified = await remoteDataSource.verifyOtp(
        email: email,
        otp: otp,
      );
      return Right(isVerified);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to verify OTP'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = await remoteDataSource.updateUserProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update profile'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await remoteDataSource.deleteAccount();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to delete account'));
    }
  }

  @override
  Stream<Either<Failure, UserEntity?>> get authStateChanges {
    return remoteDataSource.authStateChanges.map((user) => Right(user));
  }
}
