import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lodbod_app/core/error/failures.dart';
import 'package:lodbod_app/features/auth/domain/entities/user_entity.dart';
import 'package:lodbod_app/features/auth/domain/repositories/auth_repository.dart';


class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(SignUpParams params) async {
    return await repository.signUpWithEmailAndPassword(
      email: params.email,
      password: params.password,
      phoneNumber: params.phoneNumber,
      displayName: params.displayName,
      companyName: params.companyName,
      role: params.role,
    );
  }
}

class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String phoneNumber;
  final String? displayName;
  final String? companyName;
  final String role;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.phoneNumber,
    this.displayName,
    this.companyName,
    this.role = 'shipper',
  });

  @override
  List<Object?> get props => [
    email,
    password,
    phoneNumber,
    displayName,
    companyName,
    role,
  ];
}
