import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/datasources/sample_bid_fixtures.dart';
import '../../domain/entities/shipment_bid_entity.dart';
import '../../domain/entities/shipment_entity.dart';
import '../../domain/utils/shipment_route.dart';
import '../bloc/bid/bid_bloc.dart';
import '../bloc/bid/bid_event.dart';
import '../bloc/bid/bid_state.dart';
import '../bloc/query/shipment_query_bloc.dart';
import '../bloc/query/shipment_query_event.dart';
import '../bloc/query/shipment_query_state.dart';

class ShipmentDetailPage extends StatefulWidget {
  const ShipmentDetailPage({required this.shipmentId, super.key});

  final String shipmentId;

  @override
  State<ShipmentDetailPage> createState() => _ShipmentDetailPageState();
}

class _ShipmentDetailPageState extends State<ShipmentDetailPage> {
  static const _orange = Color(0xFFE84012);
  Color get _ink => Theme.of(context).colorScheme.onSurface;
  Color get _muted => Theme.of(context).colorScheme.onSurfaceVariant;
  Color get _background => Theme.of(context).scaffoldBackgroundColor;

  ShipmentEntity? _updatedShipment;
  bool _shipmentUpdated = false;
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final profile = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (mounted) setState(() => _role = profile.data()?['role'] as String?);
  }

  List<ShipmentBidEntity> _bidsFor(ShipmentEntity shipment) =>
      _role == 'carrier'
      ? shipment.bids
      : SampleBidFixtures.forShipment(
          status: shipment.status,
          savedBids: shipment.bids,
        );

  Future<void> _acceptBid(
    ShipmentEntity shipment,
    ShipmentBidEntity bid,
    BuildContext blocContext,
  ) async {
    final carrier = bid.carrier;
    final fare = bid.fare;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Accept this bid?'),
        content: Text(
          'Assign this shipment to $carrier for ${formatNpr(fare)}? The shipment status will move to Scheduled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Accept bid'),
          ),
        ],
      ),
    );
    if (confirmed != true || !blocContext.mounted) return;

    blocContext.read<BidBloc>().add(
      AcceptBid(
        shipment: shipment,
        selectedBid: bid,
        availableBids: _bidsFor(shipment),
      ),
    );
  }

  String _text(String? value, [String fallback = 'Not provided']) =>
      value == null || value.isEmpty ? fallback : value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => context.pop(_shipmentUpdated),
          icon: Icon(Icons.arrow_back_rounded),
        ),
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Shipment details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                di.sl<ShipmentQueryBloc>()..add(const LoadShipments()),
          ),
          BlocProvider(create: (_) => di.sl<BidBloc>()),
        ],
        child: BlocListener<BidBloc, BidState>(
          listener: (context, bidState) {
            if (bidState is BidSubmissionFailure) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(bidState.message)));
            } else if (bidState is BidAcceptanceSuccess) {
              _shipmentUpdated = true;
              setState(() => _updatedShipment = bidState.shipment);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Bid accepted. ${bidState.shipment.assignedCarrier} is assigned.',
                  ),
                ),
              );
            }
          },
          child: BlocBuilder<ShipmentQueryBloc, ShipmentQueryState>(
            builder: (context, state) {
              if (state.status == ShipmentQueryStatus.initial ||
                  state.status == ShipmentQueryStatus.loading) {
                return const LoadingSkeleton(
                  layout: LoadingSkeletonLayout.detail,
                );
              }
              if (state.status == ShipmentQueryStatus.failure) {
                return const Center(
                  child: Text('Could not load shipment details'),
                );
              }
              final shipment =
                  _updatedShipment ??
                  state.shipments
                      .where((item) => item.id == widget.shipmentId)
                      .firstOrNull;
              if (shipment == null) {
                return const Center(child: Text('Shipment not found'));
              }
              return _content(
                shipment,
                context,
                context.watch<BidBloc>().state is BidSubmitting,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _content(
    ShipmentEntity shipment,
    BuildContext queryContext,
    bool isAcceptingBid,
  ) {
    final reference = _text(shipment.reference, shipment.id);
    final pickupDate = shipment.pickupAt;
    final createdAt = shipment.createdAt;
    final routePoints = shipmentRoutePoints(shipment);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
      children: [
        _panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      reference,
                      style: TextStyle(
                        color: _ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  StatusBadge(status: shipment.status),
                ],
              ),
              const SizedBox(height: 18),
              for (var index = 0; index < routePoints.length; index++) ...[
                if (index > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 9),
                    child: Container(
                      width: 1,
                      height: 24,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                _routePoint(
                  routePoints[index].label,
                  routePoints[index].location,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => context.push('/shipment/${shipment.id}/track'),
          icon: Icon(Icons.map_outlined),
          label: Text('View route'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _orange,
            side: const BorderSide(color: _orange),
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _section('Load information', [
          _detailRow('Cargo', _text(shipment.cargoDescription)),
          _detailRow('Category', _text(shipment.cargoCategory)),
          _detailRow(
            'Weight',
            '${shipment.weight?.toString() ?? 'Not provided'} '
                    '${shipment.weightUnit ?? ''}'
                .trim(),
          ),
          _detailRow('Vehicle', _text(shipment.vehicleType)),
        ]),
        const SizedBox(height: 12),
        _section('Schedule and contact', [
          _detailRow(
            'Pickup',
            pickupDate == null
                ? 'Not scheduled'
                : DateFormat('EEE, d MMM yyyy · h:mm a').format(pickupDate),
          ),
          _detailRow(
            'Expected fare',
            shipment.expectedFare == null
                ? 'Open for bids'
                : formatNpr(shipment.expectedFare!),
          ),
          _detailRow('Contact', _text(shipment.contactNumber)),
          _detailRow('Notes', _text(shipment.notes)),
        ]),
        const SizedBox(height: 12),
        _section('Shipment timeline', [
          if (createdAt != null)
            _timelineEntry(
              'Shipment posted',
              DateFormat('d MMM yyyy · h:mm a').format(createdAt),
              true,
            ),
          if (shipment.statusHistory.isNotEmpty)
            ...shipment.statusHistory.map((event) {
              return _timelineEntry(
                event.status,
                event.at == null
                    ? ''
                    : DateFormat('d MMM yyyy · h:mm a').format(event.at!),
                true,
              );
            })
          else
            _timelineEntry('Current status: ${shipment.status}', '', true),
        ]),
        if (const {
          'pending',
          'awaiting bids',
        }.contains(shipment.status.toLowerCase().replaceAll('_', ' '))) ...[
          const SizedBox(height: 12),
          _section('Carrier bids', [
            if (_role != 'carrier' &&
                shipment.bids.isEmpty &&
                _bidsFor(shipment).isNotEmpty) ...[
              Text(
                'Fictional assessment examples',
                style: TextStyle(color: _muted, fontSize: 10),
              ),
              const SizedBox(height: 4),
            ],
            if (_bidsFor(shipment).isEmpty)
              Text(
                'No carrier bids yet.',
                style: TextStyle(color: _muted, fontSize: 11),
              )
            else
              for (final bid in _bidsFor(shipment))
                _bidCard(shipment, bid, queryContext, isAcceptingBid),
            if (_role == 'carrier' &&
                !_bidsFor(shipment).any(
                  (bid) => bid.id == FirebaseAuth.instance.currentUser?.uid,
                ))
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: FilledButton.icon(
                  onPressed: () async {
                    final submitted = await context.push<bool>(
                      '/create-bid/${shipment.id}',
                    );
                    if (submitted == true && queryContext.mounted) {
                      queryContext.read<ShipmentQueryBloc>().add(
                        const LoadShipments(),
                      );
                    }
                  },
                  icon: Icon(Icons.gavel_rounded),
                  label: Text('Place a bid'),
                  style: FilledButton.styleFrom(backgroundColor: _orange),
                ),
              ),
          ]),
        ],
        if (shipment.acceptedBid != null) ...[
          const SizedBox(height: 12),
          _section('Accepted bid', [
            _detailRow(
              'Carrier',
              _text(shipment.assignedCarrier, 'Not provided'),
            ),
            _detailRow(
              'Fare',
              formatNpr(shipment.expectedFare ?? shipment.acceptedBid!.fare),
            ),
          ]),
        ],
        if (shipment.status.toLowerCase() == 'awaiting_bids' ||
            shipment.status.toLowerCase() == 'pending') ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => context.pop(),
            icon: Icon(Icons.edit_outlined),
            label: Text('Back to shipments'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _orange,
              side: const BorderSide(color: _orange),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _bidCard(
    ShipmentEntity shipment,
    ShipmentBidEntity bid,
    BuildContext queryContext,
    bool isAcceptingBid,
  ) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  bid.carrier,
                  style: TextStyle(
                    color: _ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                formatNpr(bid.fare),
                style: TextStyle(
                  color: _ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Rating ${bid.rating}/5 · delivery in ${bid.deliveryDays} days',
            style: TextStyle(color: _muted, fontSize: 11),
          ),
          if (_role == 'shipper') ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: isAcceptingBid
                    ? null
                    : () => _acceptBid(shipment, bid, queryContext),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _orange,
                  side: const BorderSide(color: _orange),
                  visualDensity: VisualDensity.compact,
                ),
                child: isAcceptingBid
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Accept bid'),
              ),
            ),
          ],
        ],
      ),
    ),
  );

  Widget _panel({required Widget child}) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: child,
  );

  Widget _section(String title, List<Widget> children) => _panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: _ink,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    ),
  );

  Widget _routePoint(String label, String location) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(Icons.location_on_rounded, size: 18, color: _orange),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: _muted, fontSize: 10)),
            const SizedBox(height: 2),
            Text(
              location,
              style: TextStyle(
                color: _ink,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 105,
          child: Text(label, style: TextStyle(color: _muted, fontSize: 11)),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: _ink,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _timelineEntry(String title, String subtitle, bool complete) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              complete ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: 16,
              color: complete ? _orange : _muted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: _ink,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(color: _muted, fontSize: 10),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
}
