import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/widgets/loading_skeleton.dart';
import '../../domain/entities/shipment_entity.dart';
import '../../../../core/widgets/bottom_navigation.dart';
import '../bloc/query/shipment_query_bloc.dart';
import '../bloc/query/shipment_query_event.dart';
import '../bloc/query/shipment_query_state.dart';
import '../widgets/shipment_card.dart';

class ShipmentListPage extends StatefulWidget {
  const ShipmentListPage({
    this.initialFilter = 'All',
    this.selectedNavIndex = 1,
    this.carrierMode = false,
    super.key,
  });

  final String initialFilter;
  final int selectedNavIndex;
  final bool carrierMode;

  @override
  State<ShipmentListPage> createState() => _ShipmentListPageState();
}

class _ShipmentListPageState extends State<ShipmentListPage> {
  static const _orange = Color(0xFFE84012);
  Color get _ink => Theme.of(context).colorScheme.onSurface;
  Color get _muted => Theme.of(context).colorScheme.onSurfaceVariant;
  Color get _background => Theme.of(context).scaffoldBackgroundColor;

  final _searchController = TextEditingController();
  late String _statusFilter = widget.initialFilter;
  DateTime? _pickupDateFilter;
  String _query = '';

  static const _filters = [
    'All',
    'Awaiting bids',
    'Scheduled',
    'In transit',
    'Delivered',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh(BuildContext queryContext) async {
    final bloc = queryContext.read<ShipmentQueryBloc>();
    bloc.add(const LoadShipments());
    await bloc.stream.firstWhere(
      (state) => state.status != ShipmentQueryStatus.loading,
    );
  }

  String _normalizedStatus(ShipmentEntity shipment) =>
      shipment.status.toLowerCase().replaceAll('_', ' ');

  bool _matchesFilter(ShipmentEntity shipment) {
    final status = _normalizedStatus(shipment);
    switch (_statusFilter) {
      case 'Awaiting bids':
        return status == 'pending' || status == 'awaiting bids';
      case 'In transit':
        return status == 'in transit' || status == 'active';
      case 'Scheduled':
        return status == 'scheduled' || status == 'confirmed';
      case 'Delivered':
        return status == 'delivered' || status == 'completed';
      default:
        return true;
    }
  }

  bool _matchesPickupDate(ShipmentEntity shipment) {
    final selectedDate = _pickupDateFilter;
    final pickupDate = shipment.pickupAt;
    return selectedDate == null ||
        (pickupDate != null &&
            pickupDate.year == selectedDate.year &&
            pickupDate.month == selectedDate.month &&
            pickupDate.day == selectedDate.day);
  }

  Future<void> _selectPickupDate() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _pickupDateFilter ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      helpText: 'Filter by pickup date',
    );
    if (selectedDate != null && mounted) {
      setState(() => _pickupDateFilter = selectedDate);
    }
  }

  Future<void> _showFilters() async {
    final selectedFilter = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter shipments',
                style: TextStyle(
                  color: _ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              for (final filter in _filters)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(filter),
                  trailing: _statusFilter == filter
                      ? Icon(Icons.check_rounded, color: _orange)
                      : null,
                  onTap: () => Navigator.pop(context, filter),
                ),
              if (_pickupDateFilter != null)
                TextButton.icon(
                  onPressed: () => Navigator.pop(context, '__clear_date__'),
                  icon: Icon(Icons.event_busy_outlined),
                  label: Text('Clear pickup date'),
                ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || selectedFilter == null) return;
    if (selectedFilter == '__clear_date__') {
      setState(() => _pickupDateFilter = null);
    } else {
      setState(() => _statusFilter = selectedFilter);
    }
  }

  bool _matchesQuery(ShipmentEntity shipment) {
    final searchable = [
      shipment.id,
      shipment.reference,
      shipment.pickupLocation,
      shipment.deliveryLocation,
      shipment.cargoDescription,
      shipment.vehicleType,
    ].whereType<Object>().join(' ').toLowerCase();
    return searchable.contains(_query.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ShipmentQueryBloc>()..add(const LoadShipments()),
      child: Scaffold(
        backgroundColor: _background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Shipments',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _HeaderAction(
                      icon: Icons.calendar_month_outlined,
                      tooltip: 'Filter by pickup date',
                      active: _pickupDateFilter != null,
                      onPressed: _selectPickupDate,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => _query = value.trim()),
                        decoration: InputDecoration(
                          hintText: 'Search reference, route, cargo',
                          prefixIcon: Icon(Icons.search_rounded, size: 20),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Clear search',
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _query = '');
                                  },
                                  icon: Icon(Icons.close_rounded, size: 18),
                                ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E5EA),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E5EA),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: _orange),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _HeaderAction(
                      icon: Icons.tune_rounded,
                      tooltip: 'Filter shipments',
                      active: _statusFilter != 'All',
                      onPressed: _showFilters,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: BlocBuilder<ShipmentQueryBloc, ShipmentQueryState>(
                  builder: (context, state) {
                    final allShipments = state.shipments;
                    final shipments = allShipments
                        .where(_matchesFilter)
                        .where(_matchesPickupDate)
                        .where(_matchesQuery)
                        .toList();

                    if (state.status == ShipmentQueryStatus.loading ||
                        state.status == ShipmentQueryStatus.initial) {
                      return const LoadingSkeleton(
                        layout: LoadingSkeletonLayout.list,
                      );
                    }
                    if (state.status == ShipmentQueryStatus.failure) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Could not load shipments'),
                            TextButton(
                              onPressed: () => _refresh(context),
                              child: Text('Try again'),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: _orange,
                      onRefresh: () => _refresh(context),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                        children: [
                          if (shipments.isEmpty)
                            _emptyState()
                          else
                            ...shipments.map(
                              (shipment) => Padding(
                                padding: const EdgeInsets.only(bottom: 9),
                                child: ShipmentCard(
                                  shipment: shipment,
                                  onShipmentUpdated: () => _refresh(context),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: widget.carrierMode
            ? null
            : Builder(
                builder: (context) => BottomNavigation(
                  selectedIndex: widget.selectedNavIndex,
                  onShipmentChanged: () => _refresh(context),
                ),
              ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 28),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, color: _muted, size: 28),
          SizedBox(height: 8),
          Text(
            'No matching shipments',
            style: TextStyle(color: _ink, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4),
          Text(
            'Try another search or status filter.',
            style: TextStyle(color: _muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.active = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 42,
    height: 42,
    child: Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(13),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 20,
          color: active
              ? _ShipmentListPageState._orange
              : Theme.of(context).colorScheme.onSurface,
        ),
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          padding: EdgeInsets.zero,
        ),
      ),
    ),
  );
}
