import 'package:equatable/equatable.dart';
import 'package:lodbod_app/features/auth/domain/entities/user_entity.dart';


abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthNeedsVerification extends AuthState {
  final String email;

  const AuthNeedsVerification(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
