import 'package:flutter/material.dart';

Widget choiceTile<T>(
  BuildContext context,
  String label,
  T value, {
  required bool selected,
}) => SimpleDialogOption(
  onPressed: () => Navigator.pop(context, value),
  child: Row(
    children: [
      Expanded(child: Text(label)),
      if (selected)
        Icon(Icons.check_rounded, color: Theme.of(context).colorScheme.primary),
    ],
  ),
);
