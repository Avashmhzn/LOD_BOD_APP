import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lodbod_app/features/auth/domain/entities/user_entity.dart';


class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    super.phoneNumber,
    super.displayName,
    super.companyName,
    super.role,
    super.photoUrl,
    required super.createdAt,
    super.lastLoginAt,
    required super.isEmailVerified,
  });

  // From Firebase User
  factory UserModel.fromFirebaseUser(
    User firebaseUser, {
    String? phoneNumber,
    String? companyName,
    String role = 'shipper',
  }) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      phoneNumber: phoneNumber ?? firebaseUser.phoneNumber,
      displayName: firebaseUser.displayName,
      companyName: companyName,
      role: role,
      photoUrl: firebaseUser.photoURL,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: firebaseUser.metadata.lastSignInTime,
      isEmailVerified: firebaseUser.emailVerified,
    );
  }

  // From Firestore Document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String?,
      displayName: data['displayName'] as String?,
      companyName: data['companyName'] as String?,
      role: data['role'] as String? ?? 'shipper',
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      isEmailVerified: data['isEmailVerified'] as bool? ?? false,
    );
  }

  // To Firestore Document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'companyName': companyName,
      'photoUrl': photoUrl,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null
          ? Timestamp.fromDate(lastLoginAt!)
          : null,
      'isEmailVerified': isEmailVerified,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? phoneNumber,
    String? displayName,
    String? companyName,
    String? role,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      companyName: companyName ?? this.companyName,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}
