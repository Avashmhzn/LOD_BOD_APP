// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get account => 'खाता';

  @override
  String get notifications => 'सूचनाहरू';

  @override
  String get notificationsUnavailable => 'सूचनाहरू अहिले उपलब्ध छैनन्।';

  @override
  String get shipper => 'सामान पठाउने';

  @override
  String get accountSection => 'खाता';

  @override
  String get profileCompany => 'प्रोफाइल र कम्पनी';

  @override
  String get teamAccess => 'टोली पहुँच';

  @override
  String get teamAccessUnavailable => 'टोली पहुँच अहिले उपलब्ध छैन।';

  @override
  String get favoriteCarriers => 'मनपर्ने ढुवानीकर्ता';

  @override
  String get favoriteCarriersUnavailable =>
      'मनपर्ने ढुवानीकर्ता अहिले उपलब्ध छैनन्।';

  @override
  String get preferences => 'प्राथमिकताहरू';

  @override
  String get language => 'भाषा';

  @override
  String get appearance => 'देखावट';

  @override
  String get integrations => 'एकीकरणहरू';

  @override
  String get integrationsUnavailable => 'एकीकरणहरू अहिले उपलब्ध छैनन्।';

  @override
  String get supportFeedback => 'सहयोग र प्रतिक्रिया';

  @override
  String get helpCenter => 'सहयोग केन्द्र';

  @override
  String get helpCenterUnavailable => 'सहयोग केन्द्र अहिले उपलब्ध छैन।';

  @override
  String get requestFeature => 'सुविधा अनुरोध गर्नुहोस्';

  @override
  String get featureRequestsUnavailable =>
      'सुविधा अनुरोधहरू अहिले उपलब्ध छैनन्।';

  @override
  String get legalSecurity => 'कानुनी र सुरक्षा';

  @override
  String get securityPassword => 'सुरक्षा र पासवर्ड';

  @override
  String get termsPrivacy => 'नियम र गोपनीयता नीति';

  @override
  String get legalUnavailable => 'कानुनी कागजातहरू अहिले उपलब्ध छैनन्।';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get deleteAccount => 'खाता मेटाउनुहोस्';

  @override
  String get profileUpdated => 'प्रोफाइल अद्यावधिक भयो।';

  @override
  String couldNotUpdateProfile(String error) {
    return 'प्रोफाइल अद्यावधिक गर्न सकिएन: $error';
  }

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get enterName => 'आफ्नो नाम लेख्नुहोस्';

  @override
  String get companyName => 'कम्पनीको नाम';

  @override
  String get cancel => 'रद्द गर्नुहोस्';

  @override
  String get save => 'सुरक्षित गर्नुहोस्';

  @override
  String get system => 'प्रणाली';

  @override
  String get light => 'उज्यालो';

  @override
  String get dark => 'गाढा';

  @override
  String get systemDefault => 'प्रणालीको पूर्वनिर्धारित';

  @override
  String get english => 'अङ्ग्रेजी';

  @override
  String get nepali => 'नेपाली';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get resetPassword => 'पासवर्ड रिसेट गर्नुहोस्';

  @override
  String resetPasswordExplanation(String email) {
    return 'Firebase ले $email मा सुरक्षित पासवर्ड रिसेट लिङ्क पठाउनेछ। यो खाताका लागि OTP बाट पासवर्ड रिकभरी उपलब्ध छैन।';
  }

  @override
  String get sendLink => 'लिङ्क पठाउनुहोस्';

  @override
  String passwordResetLinkSent(String email) {
    return 'पासवर्ड रिसेट लिङ्क $email मा पठाइयो।';
  }

  @override
  String couldNotSendResetLink(String error) {
    return 'रिसेट लिङ्क पठाउन सकिएन: $error';
  }

  @override
  String get signOutQuestion => 'साइन आउट गर्ने?';

  @override
  String get signBackInAnytime =>
      'तपाईं जुनसुकै बेला फेरि साइन इन गर्न सक्नुहुन्छ।';

  @override
  String couldNotSignOut(String error) {
    return 'साइन आउट गर्न सकिएन: $error';
  }

  @override
  String get deleteAccountQuestion => 'खाता मेटाउने?';

  @override
  String get deleteAccountWarning =>
      'यसले तपाईंको खाता र प्रोफाइल स्थायी रूपमा मेटाउनेछ। यो कार्य फिर्ता गर्न सकिँदैन।';

  @override
  String get typeDeleteToConfirm => 'पुष्टि गर्न DELETE लेख्नुहोस्';

  @override
  String couldNotDeleteAccount(String error) {
    return 'खाता मेटाउन सकिएन: $error';
  }

  @override
  String get adminRole => 'प्रशासक';

  @override
  String get carrierRole => 'ढुवानीकर्ता';
}
