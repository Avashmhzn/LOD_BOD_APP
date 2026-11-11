import 'package:flutter/material.dart';

class LoadErrorWidget extends StatelessWidget {
  const LoadErrorWidget({super.key, required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            'Could not load shipments',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          TextButton(onPressed: onRetry, child: Text('Try again')),
        ],
      ),
    );
  }
}
