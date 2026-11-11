import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ne.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('ne'),
  ];

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Notifications are not available yet.'**
  String get notificationsUnavailable;

  /// No description provided for @shipper.
  ///
  /// In en, this message translates to:
  /// **'Shipper'**
  String get shipper;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get accountSection;

  /// No description provided for @profileCompany.
  ///
  /// In en, this message translates to:
  /// **'Profile & company'**
  String get profileCompany;

  /// No description provided for @teamAccess.
  ///
  /// In en, this message translates to:
  /// **'Team access'**
  String get teamAccess;

  /// No description provided for @teamAccessUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Team access is not available yet.'**
  String get teamAccessUnavailable;

  /// No description provided for @favoriteCarriers.
  ///
  /// In en, this message translates to:
  /// **'Favorite carriers'**
  String get favoriteCarriers;

  /// No description provided for @favoriteCarriersUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Favorite carriers are not available yet.'**
  String get favoriteCarriersUnavailable;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get preferences;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @integrations.
  ///
  /// In en, this message translates to:
  /// **'Integrations'**
  String get integrations;

  /// No description provided for @integrationsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Integrations are not available yet.'**
  String get integrationsUnavailable;

  /// No description provided for @supportFeedback.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT & FEEDBACK'**
  String get supportFeedback;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help center'**
  String get helpCenter;

  /// No description provided for @helpCenterUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Help center is not available yet.'**
  String get helpCenterUnavailable;

  /// No description provided for @requestFeature.
  ///
  /// In en, this message translates to:
  /// **'Request a feature'**
  String get requestFeature;

  /// No description provided for @featureRequestsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Feature requests are not available yet.'**
  String get featureRequestsUnavailable;

  /// No description provided for @legalSecurity.
  ///
  /// In en, this message translates to:
  /// **'LEGAL & SECURITY'**
  String get legalSecurity;

  /// No description provided for @securityPassword.
  ///
  /// In en, this message translates to:
  /// **'Security & password'**
  String get securityPassword;

  /// No description provided for @termsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Terms · Privacy policy'**
  String get termsPrivacy;

  /// No description provided for @legalUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Legal documents are not available yet.'**
  String get legalUnavailable;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated.'**
  String get profileUpdated;

  /// No description provided for @couldNotUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not update profile: {error}'**
  String couldNotUpdateProfile(String error);

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterName;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get companyName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @nepali.
  ///
  /// In en, this message translates to:
  /// **'नेपाली'**
  String get nepali;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get hindi;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @resetPasswordExplanation.
  ///
  /// In en, this message translates to:
  /// **'Firebase will send a secure password reset link to {email}. OTP-based password recovery is not available for this account.'**
  String resetPasswordExplanation(String email);

  /// No description provided for @sendLink.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get sendLink;

  /// No description provided for @passwordResetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to {email}.'**
  String passwordResetLinkSent(String email);

  /// No description provided for @couldNotSendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Could not send reset link: {error}'**
  String couldNotSendResetLink(String error);

  /// No description provided for @signOutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutQuestion;

  /// No description provided for @signBackInAnytime.
  ///
  /// In en, this message translates to:
  /// **'You can sign back in at any time.'**
  String get signBackInAnytime;

  /// No description provided for @couldNotSignOut.
  ///
  /// In en, this message translates to:
  /// **'Could not sign out: {error}'**
  String couldNotSignOut(String error);

  /// No description provided for @deleteAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountQuestion;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account and profile. This action cannot be undone.'**
  String get deleteAccountWarning;

  /// No description provided for @typeDeleteToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm'**
  String get typeDeleteToConfirm;

  /// No description provided for @couldNotDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Could not delete account: {error}'**
  String couldNotDeleteAccount(String error);

  /// No description provided for @adminRole.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminRole;

  /// No description provided for @carrierRole.
  ///
  /// In en, this message translates to:
  /// **'Carrier'**
  String get carrierRole;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ne':
      return AppLocalizationsNe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
