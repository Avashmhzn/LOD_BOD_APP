// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get account => 'Account';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsUnavailable => 'Notifications are not available yet.';

  @override
  String get shipper => 'Shipper';

  @override
  String get accountSection => 'ACCOUNT';

  @override
  String get profileCompany => 'Profile & company';

  @override
  String get teamAccess => 'Team access';

  @override
  String get teamAccessUnavailable => 'Team access is not available yet.';

  @override
  String get favoriteCarriers => 'Favorite carriers';

  @override
  String get favoriteCarriersUnavailable =>
      'Favorite carriers are not available yet.';

  @override
  String get preferences => 'PREFERENCES';

  @override
  String get language => 'Language';

  @override
  String get appearance => 'Appearance';

  @override
  String get integrations => 'Integrations';

  @override
  String get integrationsUnavailable => 'Integrations are not available yet.';

  @override
  String get supportFeedback => 'SUPPORT & FEEDBACK';

  @override
  String get helpCenter => 'Help center';

  @override
  String get helpCenterUnavailable => 'Help center is not available yet.';

  @override
  String get requestFeature => 'Request a feature';

  @override
  String get featureRequestsUnavailable =>
      'Feature requests are not available yet.';

  @override
  String get legalSecurity => 'LEGAL & SECURITY';

  @override
  String get securityPassword => 'Security & password';

  @override
  String get termsPrivacy => 'Terms · Privacy policy';

  @override
  String get legalUnavailable => 'Legal documents are not available yet.';

  @override
  String get signOut => 'Sign out';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get profileUpdated => 'Profile updated.';

  @override
  String couldNotUpdateProfile(String error) {
    return 'Could not update profile: $error';
  }

  @override
  String get fullName => 'Full name';

  @override
  String get enterName => 'Enter your name';

  @override
  String get companyName => 'Company name';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get systemDefault => 'System default';

  @override
  String get english => 'English';

  @override
  String get nepali => 'नेपाली';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get resetPassword => 'Reset password';

  @override
  String resetPasswordExplanation(String email) {
    return 'Firebase will send a secure password reset link to $email. OTP-based password recovery is not available for this account.';
  }

  @override
  String get sendLink => 'Send link';

  @override
  String passwordResetLinkSent(String email) {
    return 'Password reset link sent to $email.';
  }

  @override
  String couldNotSendResetLink(String error) {
    return 'Could not send reset link: $error';
  }

  @override
  String get signOutQuestion => 'Sign out?';

  @override
  String get signBackInAnytime => 'You can sign back in at any time.';

  @override
  String couldNotSignOut(String error) {
    return 'Could not sign out: $error';
  }

  @override
  String get deleteAccountQuestion => 'Delete account?';

  @override
  String get deleteAccountWarning =>
      'This permanently deletes your account and profile. This action cannot be undone.';

  @override
  String get typeDeleteToConfirm => 'Type DELETE to confirm';

  @override
  String couldNotDeleteAccount(String error) {
    return 'Could not delete account: $error';
  }

  @override
  String get adminRole => 'Admin';

  @override
  String get carrierRole => 'Carrier';
}
