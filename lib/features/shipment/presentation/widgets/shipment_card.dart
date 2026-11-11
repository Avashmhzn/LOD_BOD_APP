import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/shipment_entity.dart';
import '../../domain/utils/shipment_route.dart';

class ShipmentCard extends StatelessWidget {
  const ShipmentCard({
    required this.shipment,
    this.onShipmentUpdated,
    super.key,
  });

  final ShipmentEntity shipment;
  final VoidCallback? onShipmentUpdated;

  static const _orange = Color(0xFFE84012);
  static const _muted = Color(0xFF81818A);
  static const _blue = Color(0xFF2878C8);
  static const _purple = Color(0xFF7652D6);
  static const _green = Color(0xFF179879);

  String _pickupDate() {
    final date = shipment.pickupAt;
    return date == null
        ? 'Date to be confirmed'
        : DateFormat('d MMM').format(date);
  }

  String _timeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);

    if (difference.isNegative || difference.inMinutes == 0) {
      return 'just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    }

    return '${difference.inDays} days ago';
  }

  ({String label, DateTime? date}) _latestActivity() {
    if (shipment.statusHistory.isNotEmpty) {
      final event = shipment.statusHistory.last;
      final status = event.status.replaceAll('_', ' ');
      final location = event.location;
      final label = status == 'awaiting bids'
          ? 'Bid'
          : location != null && location.isNotEmpty
          ? '${status.toLowerCase().contains('pass') ? 'Passed' : status} $location'
          : status;

      return (
        label: label.isEmpty ? 'Shipment updated' : label,
        date: event.at,
      );
    }

    return (
      label: _displayStatus(shipment.status),
      date: shipment.updatedAt ?? shipment.createdAt,
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase().replaceAll('_', ' ')) {
      case 'in transit':
      case 'active':
        return _orange;

      case 'completed':
      case 'delivered':
        return _green;

      case 'pending':
      case 'awaiting bids':
        return _blue;

      case 'scheduled':
        return _purple;

      default:
        return _muted;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase().replaceAll('_', ' ')) {
      case 'in transit':
      case 'active':
        return Icons.local_shipping_rounded;

      case 'awaiting bids':
        return Icons.gavel_rounded;

      case 'scheduled':
        return Icons.event_available_rounded;

      case 'completed':
      case 'delivered':
        return Icons.check_circle_rounded;

      case 'pending':
        return Icons.schedule_rounded;

      default:
        return Icons.info_outline_rounded;
    }
  }

  String get _reference => shipment.reference ?? shipment.id.toUpperCase();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final route = shipmentRouteSummary(shipment);
    final status = shipment.status;
    final cargo = shipment.cargoDescription ?? '';
    final weightLabel = shipment.weight == null
        ? ''
        : '${shipment.weight} ${shipment.weightUnit ?? ''}'.trim();
    final cargoLabel = [
      cargo,
      weightLabel,
    ].where((value) => value.isNotEmpty).join(' · ');

    final activity = _latestActivity();
    final statusColor = _statusColor(status);

    final fareLabel = shipment.expectedFare == null
        ? null
        : formatNpr(shipment.expectedFare!);

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: () async {
          final updated = await context.push<bool>('/shipment/${shipment.id}');
          if (updated == true) onShipmentUpdated?.call();
        },
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: isDark ? colors.outlineVariant : const Color(0xFFE2E5E9),
            ),
            boxShadow: isDark
                ? const []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reference ID + Status badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _reference,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFF777780),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_statusIcon(status), size: 11, color: statusColor),
                        const SizedBox(width: 3),
                        Text(
                          _displayStatus(status),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Show the complete route, including any intermediate stops.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1, right: 6),
                    child: Icon(Icons.route_outlined, size: 14, color: _orange),
                  ),
                  Expanded(
                    child: Text(
                      route,
                      softWrap: true,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              // Cargo, weight, and pickup date
              Row(
                children: [
                  if (cargoLabel.isNotEmpty)
                    Flexible(
                      child: _meta(
                        context,
                        Icons.inventory_2_outlined,
                        cargoLabel,
                      ),
                    ),
                  if (cargoLabel.isNotEmpty) const SizedBox(width: 10),
                  _meta(context, Icons.calendar_today_outlined, _pickupDate()),
                ],
              ),

              const SizedBox(height: 8),

              // Divider
              Divider(height: 1, thickness: 0.7, color: colors.outlineVariant),

              const SizedBox(height: 7),

              // Latest tracking update + Price
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 13,
                    color: colors.onSurfaceVariant,
                  ),

                  const SizedBox(width: 3),

                  Expanded(
                    child: Text(
                      activity.date == null
                          ? activity.label
                          : '${activity.label} · ${_timeAgo(activity.date!)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  if (fareLabel != null)
                    Text(
                      fareLabel,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  if (fareLabel == null && _isAwaitingBids(status)) ...[
                    Text(
                      '${shipment.bidCount} bids',
                      style: TextStyle(
                        color: _orange,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Fare pending',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _meta(BuildContext context, IconData icon, String label) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: colors.onSurfaceVariant),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  static bool _isAwaitingBids(String status) =>
      status.toLowerCase().replaceAll('_', ' ').contains('bid') ||
      status.toLowerCase() == 'pending';

  static String _displayStatus(String status) {
    switch (status.toLowerCase().replaceAll('_', ' ')) {
      case 'awaiting bids':
        return 'Awaiting bids';

      case 'delivered':
        return 'Delivered';

      case 'scheduled':
        return 'Scheduled';

      case 'in transit':
        return 'In transit';

      default:
        return status.isEmpty ? 'Pending' : status;
    }
  }
}
