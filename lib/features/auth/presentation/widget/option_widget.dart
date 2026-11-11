import 'package:flutter/material.dart';

class LoginOptionsWidget extends StatelessWidget {
  const LoginOptionsWidget({
    super.key,
    required this.isLoading,
    required this.keepSignedIn,
    required this.onKeepSignedInChanged,
    required this.onForgotPassword,
    required this.activeColor,
    required this.mutedColor,
    required this.borderColor,
  });

  final bool isLoading;
  final bool keepSignedIn;
  final ValueChanged<bool> onKeepSignedInChanged;
  final VoidCallback onForgotPassword;
  final Color activeColor;
  final Color mutedColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onKeepSignedInChanged(!keepSignedIn),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: keepSignedIn
                      ? activeColor
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: keepSignedIn ? activeColor : borderColor,
                    width: 1.5,
                  ),
                ),
                child: keepSignedIn
                    ? Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 10),
              Text(
                'Keep me signed in',
                style: TextStyle(fontSize: 12.5, color: mutedColor),
              ),
            ],
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: isLoading ? null : onForgotPassword,
          child: Text(
            'Forgot password?',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: activeColor,
            ),
          ),
        ),
      ],
    );
  }
}
