import 'package:flutter/material.dart';

class RegisterHeaderWidget extends StatelessWidget {
  const RegisterHeaderWidget({
    super.key,
    required this.inkColor,
    required this.borderColor,
    required this.onBack,
  });

  final Color inkColor;
  final Color borderColor;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
            side: BorderSide(color: borderColor),
          ),
          child: IconButton(
            tooltip: 'Back',
            onPressed: onBack,
            icon: Icon(Icons.arrow_back_rounded, size: 20, color: inkColor),
            constraints: const BoxConstraints.tightFor(width: 40, height: 40),
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: inkColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Step 1 of 2 · Shipper details',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
