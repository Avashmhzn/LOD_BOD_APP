// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get account => 'खाता';

  @override
  String get notifications => 'सूचनाएँ';

  @override
  String get notificationsUnavailable => 'सूचनाएँ अभी उपलब्ध नहीं हैं।';

  @override
  String get shipper => 'माल भेजने वाला';

  @override
  String get accountSection => 'खाता';

  @override
  String get profileCompany => 'प्रोफ़ाइल और कंपनी';

  @override
  String get teamAccess => 'टीम की पहुँच';

  @override
  String get teamAccessUnavailable => 'टीम की पहुँच अभी उपलब्ध नहीं है।';

  @override
  String get favoriteCarriers => 'पसंदीदा वाहक';

  @override
  String get favoriteCarriersUnavailable => 'पसंदीदा वाहक अभी उपलब्ध नहीं हैं।';

  @override
  String get preferences => 'प्राथमिकताएँ';

  @override
  String get language => 'भाषा';

  @override
  String get appearance => 'दिखावट';

  @override
  String get integrations => 'एकीकरण';

  @override
  String get integrationsUnavailable => 'एकीकरण अभी उपलब्ध नहीं हैं।';

  @override
  String get supportFeedback => 'सहायता और सुझाव';

  @override
  String get helpCenter => 'सहायता केंद्र';

  @override
  String get helpCenterUnavailable => 'सहायता केंद्र अभी उपलब्ध नहीं है।';

  @override
  String get requestFeature => 'सुविधा का अनुरोध करें';

  @override
  String get featureRequestsUnavailable => 'सुविधा अनुरोध अभी उपलब्ध नहीं हैं।';

  @override
  String get legalSecurity => 'कानूनी और सुरक्षा';

  @override
  String get securityPassword => 'सुरक्षा और पासवर्ड';

  @override
  String get termsPrivacy => 'नियम और गोपनीयता नीति';

  @override
  String get legalUnavailable => 'कानूनी दस्तावेज़ अभी उपलब्ध नहीं हैं।';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get deleteAccount => 'खाता हटाएँ';

  @override
  String get profileUpdated => 'प्रोफ़ाइल अपडेट की गई।';

  @override
  String couldNotUpdateProfile(String error) {
    return 'प्रोफ़ाइल अपडेट नहीं हो सकी: $error';
  }

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get enterName => 'अपना नाम दर्ज करें';

  @override
  String get companyName => 'कंपनी का नाम';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get save => 'सहेजें';

  @override
  String get system => 'सिस्टम';

  @override
  String get light => 'लाइट';

  @override
  String get dark => 'डार्क';

  @override
  String get systemDefault => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get english => 'अंग्रेज़ी';

  @override
  String get nepali => 'नेपाली';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get resetPassword => 'पासवर्ड रीसेट करें';

  @override
  String resetPasswordExplanation(String email) {
    return 'Firebase $email पर सुरक्षित पासवर्ड रीसेट लिंक भेजेगा। इस खाते के लिए OTP से पासवर्ड रिकवरी उपलब्ध नहीं है।';
  }

  @override
  String get sendLink => 'लिंक भेजें';

  @override
  String passwordResetLinkSent(String email) {
    return 'पासवर्ड रीसेट लिंक $email पर भेज दिया गया है।';
  }

  @override
  String couldNotSendResetLink(String error) {
    return 'रीसेट लिंक नहीं भेजा जा सका: $error';
  }

  @override
  String get signOutQuestion => 'साइन आउट करें?';

  @override
  String get signBackInAnytime => 'आप कभी भी फिर से साइन इन कर सकते हैं।';

  @override
  String couldNotSignOut(String error) {
    return 'साइन आउट नहीं हो सका: $error';
  }

  @override
  String get deleteAccountQuestion => 'खाता हटाएँ?';

  @override
  String get deleteAccountWarning =>
      'इससे आपका खाता और प्रोफ़ाइल हमेशा के लिए हट जाएगी। यह कार्रवाई वापस नहीं की जा सकती।';

  @override
  String get typeDeleteToConfirm => 'पुष्टि के लिए DELETE लिखें';

  @override
  String couldNotDeleteAccount(String error) {
    return 'खाता नहीं हटाया जा सका: $error';
  }

  @override
  String get adminRole => 'एडमिन';

  @override
  String get carrierRole => 'वाहक';
}
