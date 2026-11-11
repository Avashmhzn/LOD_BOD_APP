import 'package:flutter/material.dart';

class RegisterTermsWidget extends StatelessWidget {
  const RegisterTermsWidget({
    super.key,
    required this.agreed,
    required this.brandColor,
    required this.mutedColor,
    required this.borderColor,
    required this.onChanged,
  });

  final bool agreed;
  final Color brandColor;
  final Color mutedColor;
  final Color borderColor;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Agree to Terms of Service and Privacy Policy',
      checked: agreed,
      child: InkWell(
        onTap: () => onChanged(!agreed),
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: agreed
                      ? brandColor
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: agreed ? brandColor : borderColor,
                    width: 1.2,
                  ),
                ),
                child: agreed
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 10.5, color: mutedColor),
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          color: brandColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: brandColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
