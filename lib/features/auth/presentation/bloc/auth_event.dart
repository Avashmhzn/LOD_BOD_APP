import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class SignInEvent extends AuthEvent {
  final String identifier;
  final String password;
  final bool isPhone;

  const SignInEvent({
    required this.identifier,
    required this.password,
    required this.isPhone,
  });

  @override
  List<Object?> get props => [identifier, password, isPhone];
}

class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String phoneNumber;
  final String? displayName;
  final String? companyName;
  final String role;

  const SignUpEvent({
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

class VerifyOtpEvent extends AuthEvent {
  final String email;
  final String otp;

  const VerifyOtpEvent({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

class ResendOtpEvent extends AuthEvent {
  final String email;

  const ResendOtpEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class SignOutEvent extends AuthEvent {}
