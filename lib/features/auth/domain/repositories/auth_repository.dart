import 'package:dartz/dartz.dart';
import 'package:lodbod_app/core/error/failures.dart';
import 'package:lodbod_app/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {

  Future<Either<Failure, UserEntity>> signInWithIdentifierAndPassword({
    required String identifier,
    required String password,
    required bool isPhone,
  });

  /// Sign up with email and password
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String phoneNumber,
    String? displayName,
    String? companyName,
    String role = 'shipper',
  });

  /// Sign out current user
  Future<Either<Failure, void>> signOut();

  /// Get current authenticated user
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Send password reset email
  Future<Either<Failure, void>> sendPasswordResetEmail({required String email});

  /// Send custom OTP for verification
  Future<Either<Failure, void>> sendCustomOtp({required String email});

  /// Verify custom OTP
  Future<Either<Failure, bool>> verifyOtp({
    required String email,
    required String otp,
  });

  /// Update user profile
  Future<Either<Failure, UserEntity>> updateUserProfile({
    String? displayName,
    String? photoUrl,
  });

  /// Delete user account
  Future<Either<Failure, void>> deleteAccount();

  /// Stream of authentication state changes
  Stream<Either<Failure, UserEntity?>> get authStateChanges;
}
