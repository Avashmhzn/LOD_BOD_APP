import 'package:flutter/material.dart';

class LoginFieldLabelWidget extends StatelessWidget {
  const LoginFieldLabelWidget({
    super.key,
    required this.text,
    this.mutedColor,
    this.requiredField = true,
  });

  final String text;
  final Color? mutedColor;
  final bool requiredField;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          text: text,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: mutedColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          children: requiredField
              ? [
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Color(0xFFE0400A)),
                  ),
                ]
              : const [],
        ),
      ),
    );
  }
}
