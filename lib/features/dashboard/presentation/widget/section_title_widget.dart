import 'package:flutter/material.dart';

class DashboardSectionTitleWidget extends StatelessWidget {
  const DashboardSectionTitleWidget(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontSize: 15,
      fontWeight: FontWeight.w800,
    ),
  );
}
