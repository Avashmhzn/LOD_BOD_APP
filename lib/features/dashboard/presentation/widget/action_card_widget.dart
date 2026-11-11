import 'package:flutter/material.dart';
import 'package:lodbod_app/features/shipment/domain/entities/shipment_entity.dart';

class ActionCardWidget extends StatelessWidget {
  const ActionCardWidget({
    super.key,
    required this.shipment,
    required this.closesIn,
    required this.onTap,
  });

  final ShipmentEntity shipment;
  final String? closesIn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reference = shipment.reference ?? shipment.id;
    final bidCount = shipment.bidCount.toString();
    final bidsLabel = shipment.bidCount == 1 ? 'bid' : 'bids';
    final route =
        '${shipment.pickupLocation ?? ''} → '
        '${shipment.deliveryLocation ?? ''}'
        '${closesIn != null ? ' · $closesIn' : ''}';
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFBFDEFF)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4F1FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.gavel_rounded,
                  size: 19,
                  color: Color(0xFF2878C8),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$bidCount new $bidsLabel on $reference',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
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
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
