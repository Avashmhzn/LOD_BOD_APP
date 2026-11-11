import 'package:flutter/material.dart';

class RegisterFieldWidget extends StatelessWidget {
  const RegisterFieldWidget({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.requiredField = true,
    this.obscureText = false,
    this.suffix,
    this.helperText,
    this.onSubmitted,
    required this.brandColor,
    required this.inkColor,
    required this.mutedColor,
    required this.borderColor,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool requiredField;
  final bool obscureText;
  final Widget? suffix;
  final String? helperText;
  final void Function(String)? onSubmitted;
  final Color brandColor;
  final Color inkColor;
  final Color mutedColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text.rich(
            TextSpan(
              text: label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: mutedColor,
              ),
              children: requiredField
                  ? [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: brandColor),
                      ),
                    ]
                  : const [],
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          onFieldSubmitted: onSubmitted,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: inkColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: mutedColor,
            ),
            prefixIcon: Icon(icon, size: 18),
            prefixIconColor: mutedColor,
            suffixIcon: suffix,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: brandColor, width: 1.3),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: brandColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: brandColor, width: 1.3),
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText!,
            style: TextStyle(fontSize: 10.5, color: mutedColor),
          ),
        ],
      ],
    );
  }
}
