import 'package:flutter/material.dart';

class EmailTextField extends StatelessWidget {
  const EmailTextField({
    required this.controller,
    required this.labelText,
    this.suffixIcon,
    this.border,
    this.focusedBorder,
    this.maxLines,
    this.keyboardType,
    this.contentPadding,
    this.enable = true,
    this.useLabelAsFixed = false,
    super.key,
  });

  final TextEditingController controller;
  final String labelText;
  final Widget? suffixIcon;
  final InputBorder? border;
  final InputBorder? focusedBorder;
  final int? maxLines;
  final TextInputType? keyboardType;
  final EdgeInsets? contentPadding;
  final bool enable;
  final bool useLabelAsFixed;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: useLabelAsFixed ? null : labelText,
        hintStyle: const TextStyle(color: Colors.white70),
        suffixIcon: suffixIcon,
        border: InputBorder.none,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[600]!, width: 0.5),
        ),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        filled: true,
        fillColor: Colors.grey[900],
      ),
    );
  }
}
