import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lodbod_app/core/di/injection_container.dart' as di;
import 'package:lodbod_app/core/theme/app_colors.dart';
import 'package:lodbod_app/core/utils/currency_formatter.dart';
import 'package:lodbod_app/core/widgets/bottom_navigation.dart';
import 'package:lodbod_app/core/widgets/loading_skeleton.dart';
import 'package:lodbod_app/features/shipment/domain/entities/shipment_entity.dart';
import 'package:lodbod_app/features/shipment/presentation/bloc/query/shipment_query_bloc.dart';
import 'package:lodbod_app/features/shipment/presentation/bloc/query/shipment_query_event.dart';
import 'package:lodbod_app/features/shipment/presentation/bloc/query/shipment_query_state.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  static const _orange = Color(0xFFE84012);
  Color get _ink => Theme.of(context).colorScheme.onSurface;
  Color get _muted => Theme.of(context).colorScheme.onSurfaceVariant;
  List<BoxShadow> get _cardShadow =>
      Theme.of(context).brightness == Brightness.dark
      ? const []
      : AppColors.cardShadow;

  String _status(ShipmentEntity shipment) =>
      shipment.status.toLowerCase().replaceAll('_', ' ');

  int _count(List<ShipmentEntity> items, Set<String> statuses) =>
      items.where((item) => statuses.contains(_status(item))).length;

  double _fareTotal(List<ShipmentEntity> items) =>
      items.fold(0, (total, item) => total + (item.expectedFare ?? 0));

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ShipmentQueryBloc>()..add(const LoadShipments()),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: const Text(
            'Analytics',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
        ),
        body: BlocBuilder<ShipmentQueryBloc, ShipmentQueryState>(
          builder: (context, state) {
            if (state.status == ShipmentQueryStatus.loading ||
                state.status == ShipmentQueryStatus.initial) {
              return LoadingSkeleton(
                layout: LoadingSkeletonLayout.analytics,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              );
            }
            if (state.status == ShipmentQueryStatus.failure) {
              return Center(
                child: TextButton(
                  onPressed: () => context.read<ShipmentQueryBloc>().add(
                    const LoadShipments(),
                  ),
                  child: const Text('Could not load analytics. Retry'),
                ),
              );
            }

            final shipments = state.shipments;
            final active = _count(shipments, {
              'active',
              'in transit',
              'in progress',
            });
            final pending = _count(shipments, {'pending', 'awaiting bids'});
            final completed = _count(shipments, {'completed', 'delivered'});
            final total = shipments.length;

            return RefreshIndicator(
              color: _orange,
              onRefresh: () async {
                final bloc = context.read<ShipmentQueryBloc>();
                bloc.add(const LoadShipments());
                await bloc.stream.firstWhere(
                  (next) => next.status != ShipmentQueryStatus.loading,
                );
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _summary(
                          'Total loads',
                          '$total',
                          Icons.inventory_2_outlined,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _summary(
                          'Expected fare',
                          formatNpr(_fareTotal(shipments)),
                          Icons.currency_rupee_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      boxShadow: _cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shipment status',
                          style: TextStyle(
                            color: _ink,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _statusRow(
                          'Active',
                          active,
                          total,
                          const Color(0xFFD94B2B),
                        ),
                        const SizedBox(height: 16),
                        _statusRow(
                          'Awaiting bids',
                          pending,
                          total,
                          const Color(0xFF2878C8),
                        ),
                        const SizedBox(height: 16),
                        _statusRow(
                          'Completed',
                          completed,
                          total,
                          const Color(0xFF169879),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      boxShadow: _cardShadow,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.insights_rounded, color: _orange),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            total == 0
                                ? 'Shipment insights will appear as you post loads.'
                                : '$total shipment${total == 1 ? '' : 's'} in your account',
                            style: TextStyle(color: _muted, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: Builder(
          builder: (context) => BottomNavigation(
            selectedIndex: 2,
            onShipmentChanged: () =>
                context.read<ShipmentQueryBloc>().add(const LoadShipments()),
          ),
        ),
      ),
    );
  }

  Widget _summary(String title, String value, IconData icon) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      boxShadow: _cardShadow,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: _orange),
        const SizedBox(height: 14),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(title, style: TextStyle(color: _muted, fontSize: 10)),
      ],
    ),
  );

  Widget _statusRow(String label, int count, int total, Color color) {
    final value = total == 0 ? 0.0 : count / total;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: TextStyle(color: _ink, fontSize: 11)),
            ),
            Text(
              '$count',
              style: TextStyle(
                color: _ink,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
