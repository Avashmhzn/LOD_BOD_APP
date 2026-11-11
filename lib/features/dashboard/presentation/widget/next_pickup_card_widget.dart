import 'package:flutter/material.dart';
import 'package:lodbod_app/features/shipment/domain/entities/shipment_entity.dart';

class NextPickupCardWidget extends StatelessWidget {
  const NextPickupCardWidget({
    super.key,
    required this.shipment,
    required this.formattedPickup,
    required this.onTap,
  });

  final ShipmentEntity shipment;
  final String? formattedPickup;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reference = shipment.reference ?? shipment.id;
    final route =
        '${shipment.pickupLocation ?? ''} → '
        '${shipment.deliveryLocation ?? ''}'
        '${formattedPickup != null ? ' · $formattedPickup' : ''}';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: isDark
              ? theme.colorScheme.outlineVariant
              : const Color(0xFFE2E5E9),
        ),
        borderRadius: BorderRadius.circular(14),
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
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.edit_calendar_outlined,
              size: 19,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next pickup · $reference',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  route,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE84012),
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Details',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
