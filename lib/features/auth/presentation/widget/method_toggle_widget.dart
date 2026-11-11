import 'package:flutter/material.dart';

import 'toggle_items_widget.dart';

class LoginMethodToggleWidget extends StatelessWidget {
  const LoginMethodToggleWidget({
    super.key,
    required this.usePhone,
    required this.onChanged,
    required this.activeColor,
    required this.inkColor,
    required this.borderColor,
  });

  final bool usePhone;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color inkColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          LoginMethodToggleItemWidget(
            selected: usePhone,
            icon: Icons.phone,
            label: 'Phone',
            activeColor: activeColor,
            inkColor: inkColor,
            onTap: () => onChanged(true),
          ),
          LoginMethodToggleItemWidget(
            selected: !usePhone,
            icon: Icons.mail_outline_rounded,
            label: 'Email',
            activeColor: activeColor,
            inkColor: inkColor,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}
