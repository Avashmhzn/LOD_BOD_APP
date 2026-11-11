class Routes {
  // Auth
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';
  static const String forgotPassword = '/forgot-password';

  // Main
  static const String dashboard = '/dashboard';
  static const String analytics = '/analytics';
  static const String account = '/account';

  // Shipment
  static const String shipments = '/shipments';
  static const String shipmentDetail = '/shipment/:id';
  static const String shipmentTracking = '/shipment/:id/track';
  static const String createShipment = '/create-shipment';
  static const String editShipment = '/edit-shipment/:id';

  // Bid
  static const String bids = '/bids';
  static const String bidDetail = '/bid/:id';
  static const String createBid = '/create-bid/:shipmentId';

  // Order
  static const String orderConfirmation = '/order-confirmation/:id';
}
