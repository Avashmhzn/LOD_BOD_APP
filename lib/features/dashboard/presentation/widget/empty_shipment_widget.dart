import 'package:flutter/material.dart';

class EmptyShipmentWidget extends StatelessWidget {
  const EmptyShipmentWidget({super.key, required this.onPostLoad});

  final VoidCallback onPostLoad;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            'No shipments yet',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Post your first load to get started.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: onPostLoad,
            icon: Icon(Icons.add_rounded, size: 17),
            label: Text('Post a load'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE84012),
            ),
          ),
        ],
      ),
    );
  }
}
