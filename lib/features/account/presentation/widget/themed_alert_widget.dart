import 'package:flutter/material.dart';

Widget themedAlert(BuildContext context, AlertDialog dialog) {
  final theme = Theme.of(context);
  return Theme(
    data: theme.copyWith(
      dialogTheme: theme.dialogTheme.copyWith(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    ),
    child: dialog,
  );
}
