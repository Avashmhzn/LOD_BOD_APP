import 'package:flutter/material.dart';

class LoginMethodToggleItemWidget extends StatelessWidget {
  const LoginMethodToggleItemWidget({
    super.key,
    required this.selected,
    required this.icon,
    required this.label,
    required this.activeColor,
    required this.inkColor,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final Color activeColor;
  final Color inkColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 44,
          decoration: BoxDecoration(
            color: selected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? Colors.white : inkColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : inkColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
