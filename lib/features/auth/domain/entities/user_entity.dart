import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String? phoneNumber;
  final String? displayName;
  final String? companyName;
  final String role;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;

  const UserEntity({
    required this.uid,
    required this.email,
    this.phoneNumber,
    this.displayName,
    this.companyName,
    this.role = 'shipper',
    this.photoUrl,
    required this.createdAt,
    this.lastLoginAt,
    required this.isEmailVerified,
  });

  @override
  List<Object?> get props => [
    uid,
    email,
    phoneNumber,
    displayName,
    companyName,
    role,
    photoUrl,
    createdAt,
    lastLoginAt,
    isEmailVerified,
  ];
}
