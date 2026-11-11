import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'label_widget.dart';

class PhoneFieldWidget extends StatelessWidget {
  const PhoneFieldWidget({
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
        LoginFieldLabelWidget(text: 'Phone number'),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d\s\-]')),
          ],
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
