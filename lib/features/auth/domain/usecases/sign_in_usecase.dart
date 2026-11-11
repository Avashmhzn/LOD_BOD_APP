import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lodbod_app/core/error/failures.dart';
import 'package:lodbod_app/features/auth/domain/entities/user_entity.dart';
import 'package:lodbod_app/features/auth/domain/repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(SignInParams params) async {
    return await repository.signInWithIdentifierAndPassword(
      identifier: params.identifier,
      password: params.password,
      isPhone: params.isPhone,
    );
  }
}

class SignInParams extends Equatable {
  final String identifier;
  final String password;
  final bool isPhone;

  const SignInParams({
    required this.identifier,
    required this.password,
    required this.isPhone,
  });

  @override
  List<Object?> get props => [identifier, password, isPhone];
}
