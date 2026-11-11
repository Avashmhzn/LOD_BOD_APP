import 'package:flutter/material.dart';
import 'package:lodbod_app/core/theme/app_colors.dart';
import 'package:lodbod_app/core/theme/app_text_styles.dart';


class StatusBadge extends StatelessWidget {
  final String status;
  final bool showIcon;

  const StatusBadge({super.key, required this.status, this.showIcon = true});

  Color _getColor() {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'awaiting bids':
        return AppColors.statusPending;
      case 'active':
      case 'in progress':
        return AppColors.statusActive;
      case 'completed':
      case 'delivered':
        return AppColors.statusCompleted;
      case 'cancelled':
      case 'rejected':
        return AppColors.statusCancelled;
      case 'in transit':
        return AppColors.statusInTransit;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getIcon() {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'awaiting bids':
        return Icons.schedule;
      case 'active':
      case 'in progress':
        return Icons.local_shipping;
      case 'completed':
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
      case 'rejected':
        return Icons.cancel;
      case 'in transit':
        return Icons.navigation;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(_getIcon(), size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            status,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
