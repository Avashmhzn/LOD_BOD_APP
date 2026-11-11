import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lodbod_app/core/constants/route_constants.dart';
import 'package:lodbod_app/core/widgets/shipper_role_gate.dart';
import 'package:lodbod_app/features/account/presentation/pages/account_page.dart';
import 'package:lodbod_app/features/auth/presentation/pages/login_page.dart';
import 'package:lodbod_app/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:lodbod_app/features/auth/presentation/pages/register_page.dart';
import 'package:lodbod_app/features/auth/presentation/pages/splash_page.dart';
import 'package:lodbod_app/features/dashboard/presentation/pages/analytics_page.dart';
import 'package:lodbod_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:lodbod_app/features/shipment/presentation/pages/create_bid_page.dart';
import 'package:lodbod_app/features/shipment/presentation/pages/create_shipment_page.dart';
import 'package:lodbod_app/features/shipment/presentation/pages/shipment_detail_page.dart';
import 'package:lodbod_app/features/shipment/presentation/pages/shipment_list_page.dart';
import 'package:lodbod_app/features/shipment/presentation/pages/shipment_tracking_page.dart';

class AppRouter {
  static Widget _shipper(Widget page) => ShipperRoleGate(child: page);

  static final GoRouter router = GoRouter(
    initialLocation: Routes.splash,
    routes: [
      // Auth Routes
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: Routes.otpVerification,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return OtpVerificationPage(email: email);
        },
      ),

      // Main Routes
      GoRoute(
        path: Routes.dashboard,
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: Routes.analytics,
        builder: (context, state) => _shipper(const AnalyticsPage()),
      ),
      GoRoute(
        path: Routes.account,
        builder: (context, state) => _shipper(const AccountPage()),
      ),

      // Shipment Routes
      GoRoute(
        path: Routes.shipments,
        builder: (context, state) => _shipper(
          ShipmentListPage(
            initialFilter: state.uri.queryParameters['filter'] ?? 'All',
          ),
        ),
      ),
      GoRoute(
        path: Routes.createShipment,
        builder: (context, state) => _shipper(const CreateShipmentPage()),
      ),
      GoRoute(
        path: Routes.shipmentDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ShipperRoleGate(
            allowedRoles: const {'shipper', 'carrier'},
            child: ShipmentDetailPage(shipmentId: id),
          );
        },
      ),
      GoRoute(
        path: Routes.shipmentTracking,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ShipperRoleGate(
            allowedRoles: const {'shipper', 'carrier'},
            child: ShipmentTrackingPage(shipmentId: id),
          );
        },
      ),

      // Bid Routes
      GoRoute(
        path: Routes.bids,
        builder: (context, state) => ShipperRoleGate(
          allowedRoles: const {'carrier'},
          child: const ShipmentListPage(
            initialFilter: 'Awaiting bids',
            carrierMode: true,
          ),
        ),
      ),
      GoRoute(
        path: Routes.createBid,
        builder: (context, state) => ShipperRoleGate(
          allowedRoles: const {'carrier'},
          child: CreateBidPage(shipmentId: state.pathParameters['shipmentId']!),
        ),
      ),

      // Order Routes
      GoRoute(
        path: Routes.orderConfirmation,
        builder: (context, state) => _shipper(const Placeholder()),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );
}
