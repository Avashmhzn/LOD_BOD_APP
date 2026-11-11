import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lodbod_app/core/error/exceptions.dart';
import 'package:lodbod_app/core/utils/logger.dart';
import 'package:lodbod_app/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithIdentifierAndPassword({
    required String identifier,
    required String password,
    required bool isPhone,
  });

  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String phoneNumber,
    String? displayName,
    String? companyName,
    String role = 'shipper',
  });

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Future<void> sendPasswordResetEmail({required String email});

  Future<void> sendCustomOtp({required String email});

  Future<bool> verifyOtp({required String email, required String otp});

  Future<UserModel> updateUserProfile({
    String? displayName,
    String? companyName,
    String? photoUrl,
  });

  Future<void> deleteAccount();

  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    required this._firebaseAuth,
    required this._firestore,
  });

  @override
  Future<UserModel> signInWithIdentifierAndPassword({
    required String identifier,
    required String password,
    required bool isPhone,
  }) async {
    try {
      AppLogger.info('Attempting ${isPhone ? 'phone' : 'email'} sign in');

      final UserCredential userCredential;
      String? phoneNumber;
      if (isPhone) {
        final lookup = await _firestore
            .collection('phone_login_lookup')
            .doc(_phoneLookupId(identifier))
            .get();
        final lookupData = lookup.data();
        final email = lookupData?['email'] as String?;
        if (email == null || email.isEmpty) {
          throw const AuthException('No account found with this phone number');
        }
        phoneNumber = lookupData?['phoneNumber'] as String?;
        userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: identifier.trim(),
          password: password,
        );
        await _ensurePhoneLoginMapping(userCredential.user!);
      }

      if (userCredential.user == null) {
        throw const AuthException('Sign in failed: No user returned');
      }

      final userModel = UserModel.fromFirebaseUser(
        userCredential.user!,
        phoneNumber: phoneNumber,
      );

      // Update last login timestamp in Firestore
      await _updateLastLogin(userModel.uid);

      AppLogger.info('Sign in successful for user: ${userModel.uid}');
      return userModel;
    } on FirebaseAuthException catch (e) {
      if (isPhone &&
          (e.code == 'invalid-credential' ||
              e.code == 'invalid-login-credentials')) {
        throw const AuthException('Incorrect password');
      }
      throw _handleFirebaseAuthException(e);
    } catch (e, stackTrace) {
      if (e is AuthException) rethrow;
      AppLogger.error('Unexpected error during sign in', e, stackTrace);
      throw AuthException('Sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String phoneNumber,
    String? displayName,
    String? companyName,
    String role = 'shipper',
  }) async {
    try {
      AppLogger.info(
        'Attempting sign up for email: ${email.substring(0, 3)}***',
      );

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user == null) {
        throw const AuthException('Sign up failed: No user returned');
      }

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user!.updateDisplayName(displayName.trim());
        await userCredential.user!.reload();
      }

      final user = _firebaseAuth.currentUser!;
      final userModel = UserModel.fromFirebaseUser(
        user,
        phoneNumber: phoneNumber.trim(),
        companyName: companyName?.trim().isEmpty ?? true
            ? null
            : companyName!.trim(),
        role: role,
      );

      // Create user document in Firestore with security rules
      await _createUserDocument(userModel);
      await _savePhoneLoginMapping(
        uid: user.uid,
        email: user.email!,
        phoneNumber: userModel.phoneNumber,
      );

      AppLogger.info('Sign up successful for user: ${userModel.uid}');
      return userModel;
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Firebase auth error during sign up', e);
      throw _handleFirebaseAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during sign up', e, stackTrace);
      throw AuthException('Sign up failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      AppLogger.info('Signing out user');
      await _firebaseAuth.signOut();
      AppLogger.info('Sign out successful');
    } catch (e, stackTrace) {
      AppLogger.error('Error during sign out', e, stackTrace);
      throw AuthException('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        return null;
      }

      // Refresh user token to ensure it's valid
      await user.reload();
      final refreshedUser = _firebaseAuth.currentUser;

      if (refreshedUser == null) {
        return null;
      }

      return UserModel.fromFirebaseUser(refreshedUser);
    } catch (e, stackTrace) {
      AppLogger.error('Error getting current user', e, stackTrace);
      throw AuthException('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      AppLogger.info(
        'Sending password reset email to: ${email.substring(0, 3)}***',
      );

      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());

      AppLogger.info('Password reset email sent successfully');
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Firebase auth error sending password reset', e);
      throw _handleFirebaseAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Error sending password reset email', e, stackTrace);
      throw AuthException(
        'Failed to send password reset email: ${e.toString()}',
      );
    }
  }

  // Removed: sendEmailVerification() override

  @override
  Future<void> sendCustomOtp({required String email}) async {
    try {
      final otpCode = (100000 + Random().nextInt(900000)).toString();

      await _firestore.collection('otp_verifications').doc(email).set({
        'code': otpCode,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(minutes: 5)),
        ),
      });

      AppLogger.info('OTP code $otpCode generated for $email');
    } catch (e) {
      throw AuthException('Failed to generate OTP: ${e.toString()}');
    }
  }

  @override
  Future<bool> verifyOtp({required String email, required String otp}) async {
    try {
      final doc = await _firestore
          .collection('otp_verifications')
          .doc(email)
          .get();

      if (!doc.exists) return false;

      final data = doc.data()!;
      final storedCode = data['code'];
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();

      if (storedCode == otp && DateTime.now().isBefore(expiresAt)) {
        // Correct Code!
        final user = _firebaseAuth.currentUser;
        if (user != null) {
          await _firestore.collection('users').doc(user.uid).update({
            'isEmailVerified': true,
          });
        }
        await doc.reference.delete(); // Clear code
        return true;
      }
      return false;
    } catch (e) {
      throw AuthException('Failed to verify OTP: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateUserProfile({
    String? displayName,
    String? companyName,
    String? photoUrl,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        throw const AuthException('No user signed in');
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName.trim());
      }

      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl.trim());
      }

      String? existingCompany;
      if (companyName == null) {
        final profile = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        existingCompany = profile.data()?['companyName'] as String?;
      }
      final updatedUser = _firebaseAuth.currentUser ?? user;
      final userModel = UserModel.fromFirebaseUser(
        updatedUser,
        companyName: companyName ?? existingCompany,
      );

      // Update Firestore document
      await _updateUserDocument(userModel);

      AppLogger.info('User profile updated successfully');
      return userModel;
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Firebase auth error updating profile', e);
      throw _handleFirebaseAuthException(e);
    } on AuthException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('Error updating user profile', e, stackTrace);
      throw AuthException('Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        throw const AuthException('No user signed in');
      }

      final uid = user.uid;

      final userDocument = await _firestore.collection('users').doc(uid).get();
      final phoneNumber = userDocument.data()?['phoneNumber'] as String?;
      if (phoneNumber != null) {
        final lookup = await _firestore
            .collection('phone_login_lookup')
            .doc(_phoneLookupId(phoneNumber))
            .get();
        if (lookup.data()?['uid'] == uid) {
          await lookup.reference.delete();
        }
      }

      // Delete user document from Firestore first
      await _firestore.collection('users').doc(uid).delete();

      // Delete Firebase Auth user
      await user.delete();

      AppLogger.info('User account deleted successfully');
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Firebase auth error deleting account', e);

      if (e.code == 'requires-recent-login') {
        throw const AuthException(
          'Please sign in again before deleting your account',
        );
      }

      throw _handleFirebaseAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting account', e, stackTrace);
      throw AuthException('Failed to delete account: ${e.toString()}');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserModel.fromFirebaseUser(user);
    });
  }

  // Private helper methods

  String _phoneLookupId(String phoneNumber) {
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    return digits.startsWith('977') && digits.length == 13
        ? digits.substring(3)
        : digits;
  }

  Future<void> _ensurePhoneLoginMapping(User user) async {
    try {
      final profile = await _firestore.collection('users').doc(user.uid).get();
      final phoneNumber = profile.data()?['phoneNumber'] as String?;
      if (phoneNumber != null && user.email != null) {
        await _savePhoneLoginMapping(
          uid: user.uid,
          email: user.email!,
          phoneNumber: phoneNumber,
        );
      }
    } catch (e) {
      AppLogger.warning('Could not prepare phone login for this account', e);
    }
  }

  Future<void> _savePhoneLoginMapping({
    required String uid,
    required String email,
    required String? phoneNumber,
  }) async {
    if (phoneNumber == null || _phoneLookupId(phoneNumber).isEmpty) return;
    try {
      await _firestore
          .collection('phone_login_lookup')
          .doc(_phoneLookupId(phoneNumber))
          .set({'uid': uid, 'email': email, 'phoneNumber': phoneNumber});
    } catch (e) {
      AppLogger.warning('Could not save phone login lookup', e);
    }
  }

  Future<void> _createUserDocument(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toFirestore(), SetOptions(merge: false));
      AppLogger.info('User document created in Firestore');
    } catch (e, stackTrace) {
      AppLogger.error('Error creating user document', e, stackTrace);
      throw const AuthException('Failed to save your account profile');
    }
  }

  Future<void> _updateUserDocument(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(user.toFirestore()..remove('role'));
      AppLogger.info('User document updated in Firestore');
    } catch (e, stackTrace) {
      AppLogger.error('Error updating user document', e, stackTrace);
      throw const AuthException('Could not save profile changes');
    }
  }

  Future<void> _updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      AppLogger.warning('Failed to update last login timestamp', e);
      // Don't throw - this is non-critical
    }
  }

  AuthException _handleFirebaseAuthException(FirebaseAuthException e) {
    String message;

    switch (e.code) {
      case 'user-not-found':
        message = 'No account found with this email';
        break;
      case 'wrong-password':
        message = 'Incorrect password';
        break;
      case 'invalid-credential':
      case 'invalid-login-credentials':
        message = 'Email or password is incorrect';
        break;
      case 'email-already-in-use':
        message = 'An account already exists with this email';
        break;
      case 'invalid-email':
        message = 'Invalid email address';
        break;
      case 'weak-password':
        message = 'Password is too weak';
        break;
      case 'user-disabled':
        message = 'This account has been disabled';
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Please try again later';
        break;
      case 'operation-not-allowed':
        message = 'This sign-in method is not enabled';
        break;
      case 'requires-recent-login':
        message = 'Please sign in again to continue';
        break;
      case 'network-request-failed':
        message = 'Network error. Please check your connection';
        break;
      default:
        message = e.message ?? 'An authentication error occurred';
    }

    return AuthException(message);
  }
}
