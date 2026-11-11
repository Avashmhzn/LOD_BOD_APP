import 'package:flutter/material.dart';

Widget group(BuildContext context, List<Widget> rows) {
  final theme = Theme.of(context);
  final colors = theme.colorScheme;
  return Material(
    color: colors.surface,
    elevation: theme.brightness == Brightness.dark ? 0 : 1,
    shadowColor: Colors.black.withValues(alpha: 0.06),
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: colors.outlineVariant),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < rows.length; index++) ...[
          rows[index],
          if (index < rows.length - 1)
            Divider(height: 1, indent: 42, color: colors.outlineVariant),
        ],
      ],
    ),
  );
}
