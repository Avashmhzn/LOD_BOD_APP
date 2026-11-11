import 'package:flutter/material.dart';

const _accent = Color(0xFFE84012);

Widget row(
  BuildContext context, {
  required IconData icon,
  required String title,
  String? value,
  VoidCallback? onTap,
  bool? switchValue,
  ValueChanged<bool>? onSwitchChanged,
}) {
  final colors = Theme.of(context).colorScheme;
  return ListTile(
    dense: true,
    visualDensity: const VisualDensity(vertical: -3),
    minTileHeight: 34,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
    leading: Icon(icon, size: 18, color: _accent),
    title: Text(
      title,
      style: Theme.of(context).textTheme.bodyMedium
          ?.copyWith(fontWeight: FontWeight.w600),
    ),
    trailing: switchValue != null
        ? Switch.adaptive(
            value: switchValue,
            onChanged: onSwitchChanged,
            activeTrackColor: _accent,
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value != null) ...[
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
                const SizedBox(width: 4),
              ],
              Icon(
                Icons.chevron_right_rounded,
                size: 19,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
    onTap: onTap,
  );
}
