import 'package:flutter/material.dart';

class EmailTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final int? maxLines;

  const EmailTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      maxLines: maxLines,
    );
  }
}
