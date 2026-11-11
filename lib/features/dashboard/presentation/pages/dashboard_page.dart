import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lodbod_app/core/constants/route_constants.dart';
import 'package:lodbod_app/core/di/injection_container.dart' as di;
import 'package:lodbod_app/core/widgets/bottom_navigation.dart';
import 'package:lodbod_app/features/dashboard/presentation/widget/action_card_widget.dart';
import 'package:lodbod_app/features/dashboard/presentation/widget/dashboard_skeleton.dart';
import 'package:lodbod_app/features/dashboard/presentation/widget/empty_shipment_widget.dart';
import 'package:lodbod_app/features/dashboard/presentation/widget/header_widget.dart';
import 'package:lodbod_app/features/dashboard/presentation/widget/load_error_widget.dart';
import 'package:lodbod_app/features/dashboard/presentation/widget/metric_widget.dart';
import 'package:lodbod_app/features/dashboard/presentation/widget/next_pickup_card_widget.dart';
import 'package:lodbod_app/features/dashboard/presentation/widget/post_load_banner_widget.dart';
import 'package:lodbod_app/features/dashboard/presentation/widget/section_title_widget.dart';
import 'package:lodbod_app/features/shipment/domain/entities/shipment_entity.dart';
import 'package:lodbod_app/features/shipment/presentation/widgets/shipment_card.dart';

import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const _orange = Color(0xFFE84012);
  Color get _background => Theme.of(context).scaffoldBackgroundColor;

  static const _requestLimit = 3;
  static const _qualifyingStatuses = {
    'open',
    'pending',
    'awaiting bids',
    'scheduled',
    'confirmed',
    'in transit',
    'active',
    'in progress',
  };

  String _status(ShipmentEntity shipment) =>
      shipment.status.toLowerCase().replaceAll('_', ' ');

  bool _isActive(ShipmentEntity shipment) =>
      const {'active', 'in transit', 'in progress'}.contains(_status(shipment));

  bool _isPending(ShipmentEntity shipment) =>
      const {'pending', 'awaiting bids'}.contains(_status(shipment));

  bool _hasPendingBids(ShipmentEntity shipment) =>
      const {'pending', 'awaiting bids'}.contains(_status(shipment)) &&
      _bidCount(shipment) > 0;

  bool _isCompleted(ShipmentEntity shipment) =>
      const {'completed', 'delivered'}.contains(_status(shipment));

  int _bidCount(ShipmentEntity shipment) => shipment.bidCount;

  int _count(
    List<ShipmentEntity> shipments,
    bool Function(ShipmentEntity) test,
  ) => shipments.where(test).length;

  int _requestsUsed(List<ShipmentEntity> shipments) => shipments
      .where((shipment) => _qualifyingStatuses.contains(_status(shipment)))
      .length
      .clamp(0, _requestLimit);

  ShipmentEntity? _nextPickup(List<ShipmentEntity> shipments) {
    final now = DateTime.now();
    final upcoming =
        shipments
            .where(
              (shipment) =>
                  shipment.pickupAt != null &&
                  shipment.pickupAt!.isAfter(now) &&
                  !_isCompleted(shipment),
            )
            .toList()
          ..sort((a, b) => a.pickupAt!.compareTo(b.pickupAt!));
    return upcoming.firstOrNull;
  }

  String? _closesIn(ShipmentEntity shipment) {
    final date = shipment.biddingClosesAt;
    if (date == null) return null;
    final diff = date.difference(DateTime.now());
    if (diff.isNegative) return 'bidding closed';
    if (diff.inHours >= 24) return 'bidding closes in ${diff.inDays}d';
    if (diff.inHours >= 1) return 'bidding closes in ${diff.inHours}h';
    return 'bidding closes in ${diff.inMinutes}m';
  }

  String _formatPickup(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month - 1]}, $hh:$mm';
  }

  String get _fullName {
    final user = di.sl<FirebaseAuth>().currentUser;
    final displayName = user?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;
    return user?.email?.split('@').first ?? 'there';
  }

  String get _initials {
    final parts = _fullName.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return 'U';
    final list = parts.toList();
    if (list.length == 1) return list.first[0].toUpperCase();
    return (list.first[0] + list.last[0]).toUpperCase();
  }

  Future<void> _refresh(BuildContext blocContext) async {
    final bloc = blocContext.read<DashboardBloc>();
    bloc.add(const LoadDashboard());
    await bloc.stream.firstWhere(
      (state) => state.status != DashboardStatus.loading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<DashboardBloc>()..add(const LoadDashboard()),
      child: Scaffold(
        backgroundColor: _background,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state.status == DashboardStatus.initial ||
                  state.status == DashboardStatus.loading) {
                return DashboardSkeleton();
              }

              if (state.role == 'signed_out') {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) context.go(Routes.login);
                });
                return const DashboardSkeleton();
              }
              if (state.role == 'carrier') {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) context.go(Routes.bids);
                });
                return const DashboardSkeleton();
              }
              if (state.role != null && state.role != 'shipper') {
                return const Center(
                  child: Text(
                    'This area is not available to your account type.',
                  ),
                );
              }

              final shipments = state.shipments;
              final actionShipment = shipments
                  .where(_hasPendingBids)
                  .firstOrNull;
              final nextPickup = _nextPickup(shipments);

              return RefreshIndicator(
                color: _orange,
                onRefresh: () => _refresh(context),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                  children: [
                    DashboardHeaderWidget(
                      fullName: _fullName,
                      initials: _initials,
                    ),
                    const SizedBox(height: 18),
                    PostLoadBannerWidget(
                      used: _requestsUsed(shipments),
                      requestLimit: _requestLimit,
                      onPostLoad: () async {
                        final created = await context.push<bool>(
                          Routes.createShipment,
                        );
                        if (created == true && context.mounted) {
                          await _refresh(context);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    if (state.status == DashboardStatus.failure)
                      LoadErrorWidget(onRetry: () => _refresh(context))
                    else ...[
                      Row(
                        children: [
                          Expanded(
                            child: MetricWidget(
                              title: 'Active',
                              count: _count(shipments, _isActive),
                              icon: Icons.local_shipping_rounded,
                              color: const Color(0xFFD94B2B),
                              tint: const Color(0xFFFFE9E3),
                              onTap: () => _openShipments('In transit'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: MetricWidget(
                              title: 'Pending',
                              count: _count(shipments, _isPending),
                              icon: Icons.gavel_rounded,
                              color: const Color(0xFF2878C8),
                              tint: const Color(0xFFE4F1FF),
                              onTap: () => _openShipments('Awaiting bids'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: MetricWidget(
                              title: 'Completed',
                              count: _count(shipments, _isCompleted),
                              icon: Icons.check_circle_outline_rounded,
                              color: const Color(0xFF169879),
                              tint: const Color(0xFFE0F6EF),
                              onTap: () => _openShipments('Delivered'),
                            ),
                          ),
                        ],
                      ),
                      if (actionShipment != null) ...[
                        const SizedBox(height: 22),
                        const DashboardSectionTitleWidget('Needs your action'),
                        const SizedBox(height: 10),
                        ActionCardWidget(
                          shipment: actionShipment,
                          closesIn: _closesIn(actionShipment),
                          onTap: () => context.push(Routes.shipments),
                        ),
                      ],
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          const Expanded(
                            child: DashboardSectionTitleWidget(
                              'Recent shipments',
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push(Routes.shipments),
                            style: TextButton.styleFrom(
                              foregroundColor: _orange,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'See all',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (shipments.isEmpty)
                        EmptyShipmentWidget(
                          onPostLoad: () => context.push(Routes.createShipment),
                        )
                      else ...[
                        ...shipments
                            .take(3)
                            .map(
                              (shipment) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: ShipmentCard(
                                  shipment: shipment,
                                  onShipmentUpdated: () => _refresh(context),
                                ),
                              ),
                            ),
                        if (nextPickup != null)
                          NextPickupCardWidget(
                            shipment: nextPickup,
                            formattedPickup: nextPickup.pickupAt == null
                                ? null
                                : _formatPickup(nextPickup.pickupAt!),
                            onTap: () => context.push(Routes.shipments),
                          ),
                      ],
                    ],
                  ],
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: Builder(
          builder: (context) => BottomNavigation(
            selectedIndex: 0,
            onShipmentChanged: () => _refresh(context),
          ),
        ),
      ),
    );
  }

  void _openShipments(String filter) {
    final query = Uri(queryParameters: {'filter': filter}).query;
    context.push('${Routes.shipments}?$query');
  }
}
