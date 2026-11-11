import 'package:flutter/material.dart';

import 'label_widget.dart';

class PasswordFieldWidget extends StatelessWidget {
  const PasswordFieldWidget({
    super.key,
    required this.controller,
    required this.textColor,
    required this.mutedColor,
    required this.decoration,
    required this.validator,
    required this.obscurePassword,
    required this.onToggleVisibility,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final Color textColor;
  final Color mutedColor;
  final InputDecoration decoration;
  final FormFieldValidator<String> validator;
  final bool obscurePassword;
  final VoidCallback onToggleVisibility;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LoginFieldLabelWidget(text: 'Password'),
        TextFormField(
          controller: controller,
          obscureText: obscurePassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: onSubmitted,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          decoration: decoration.copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: mutedColor,
              ),
              onPressed: onToggleVisibility,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
