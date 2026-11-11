class AppConstants {
  // App Info
  static const String appName = 'Lod Bod';
  static const String appVersion = '1.0.0';
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  // Cache
  static const Duration cacheExpiry = Duration(hours: 24);
  static const int maxCacheSize = 100;
  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 3;
  static const int maxNameLength = 50;
  // Business Rules
  static const int maxActiveBidsPerUser = 3;
  static const int maxShipmentWeight = 50000;
  static const int minShipmentWeight = 1;
  // UI
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  // Storage Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  // Error Messages
  static const String errorNetwork = 'Network connection failed';
  static const String errorServer = 'Server error occurred';
  static const String errorUnknown = 'An unexpected error occurred';
  static const String errorSessionExpired =
      'Session expired, please login again';
  // Success Messages
  static const String successLogin = 'Logged in successfully';
  static const String successLogout = 'Logged out successfully';
  static const String successShipmentCreated = 'Shipment created successfully';
  static const String successBidPlaced = 'Bid placed successfully';
}
