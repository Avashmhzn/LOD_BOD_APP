import 'package:flutter/material.dart';

class LoginDividerWidget extends StatelessWidget {
  const LoginDividerWidget({
    super.key,
    required this.borderColor,
    required this.mutedColor,
  });

  final Color borderColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: borderColor, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('or', style: TextStyle(fontSize: 12, color: mutedColor)),
        ),
        Expanded(child: Divider(color: borderColor, height: 1)),
      ],
    );
  }
}
