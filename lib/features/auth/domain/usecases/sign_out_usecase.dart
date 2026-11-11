import 'package:dartz/dartz.dart';
import 'package:lodbod_app/core/error/failures.dart';
import 'package:lodbod_app/features/auth/domain/repositories/auth_repository.dart';


class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.signOut();
  }
}
