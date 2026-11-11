import 'package:flutter/material.dart';

class CreateAccountButtonWidget extends StatelessWidget {
  const CreateAccountButtonWidget({
    super.key,
    required this.isLoading,
    required this.surfaceColor,
    required this.textColor,
    required this.borderColor,
    required this.onPressed,
  });

  final bool isLoading;
  final Color surfaceColor;
  final Color textColor;
  final Color borderColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: surfaceColor,
          foregroundColor: textColor,
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'Create a shipper account',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
