import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lodbod_app/core/error/failures.dart';
import 'package:lodbod_app/features/auth/domain/repositories/auth_repository.dart';


class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<Either<Failure, bool>> call(VerifyOtpParams params) async {
    return await repository.verifyOtp(email: params.email, otp: params.otp);
  }
}

class VerifyOtpParams extends Equatable {
  final String email;
  final String otp;

  const VerifyOtpParams({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}
