import 'package:flutter/material.dart';

Widget sectionLabel(BuildContext context, String label) => Padding(
    padding: const EdgeInsets.only(left: 2, bottom: 6),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
    ),
  );