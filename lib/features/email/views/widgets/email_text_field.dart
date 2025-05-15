import 'package:flutter/material.dart';

class EmailTextField extends StatelessWidget {
  const EmailTextField({
    required this.controller,
    required this.labelText,
    super.key,
    this.maxLines = 1,
    this.border,
    this.focusedBorder,
    this.keyboardType,
    this.contentPadding,
  });

  final TextEditingController controller;
  final String labelText;
  final int? maxLines;
  final InputBorder? border;
  final InputBorder? focusedBorder;
  final TextInputType? keyboardType;
  final EdgeInsets? contentPadding;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        border: border ?? const UnderlineInputBorder(),
        enabledBorder: border ?? const UnderlineInputBorder(),
        focusedBorder:
            focusedBorder ??
            const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
        contentPadding:
            contentPadding ?? const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
