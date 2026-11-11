import 'package:dartz/dartz.dart';
import 'package:lodbod_app/core/error/failures.dart';
import 'package:lodbod_app/features/auth/domain/entities/user_entity.dart';
import 'package:lodbod_app/features/auth/domain/repositories/auth_repository.dart';


class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, UserEntity?>> call() async {
    return await repository.getCurrentUser();
  }
}
