import 'package:flutter/material.dart';

import 'label_widget.dart';

class EmailFieldWidget extends StatelessWidget {
  const EmailFieldWidget({
    super.key,
    required this.controller,
    required this.textColor,
    required this.decoration,
    required this.validator,
  });

  final TextEditingController controller;
  final Color textColor;
  final InputDecoration decoration;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LoginFieldLabelWidget(text: 'Email address'),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          decoration: decoration,
          validator: validator,
        ),
      ],
    );
  }
}
