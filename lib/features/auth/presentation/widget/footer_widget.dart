import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginFooterWidget extends StatelessWidget {
  const LoginFooterWidget({
    super.key,
    required this.mutedColor,
    required this.linkColor,
    required this.termsTap,
    required this.privacyTap,
  });

  final Color mutedColor;
  final Color linkColor;
  final GestureRecognizer termsTap;
  final GestureRecognizer privacyTap;

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(fontSize: 11.5, color: mutedColor);
    final link = TextStyle(
      fontSize: 11.5,
      color: linkColor,
      fontWeight: FontWeight.w600,
    );
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          const TextSpan(text: 'By continuing you agree to the '),
          TextSpan(text: 'Terms', style: link, recognizer: termsTap),
          const TextSpan(text: ' and '),
          TextSpan(text: 'Privacy Policy', style: link, recognizer: privacyTap),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
