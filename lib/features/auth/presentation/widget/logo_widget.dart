import 'package:flutter/material.dart';

class LoginLogoWidget extends StatelessWidget {
  const LoginLogoWidget({super.key});

  static const _brand = Color(0xFFE0400A);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: _brand,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _brand.withValues(alpha: 0.30),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          Icons.local_shipping_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
