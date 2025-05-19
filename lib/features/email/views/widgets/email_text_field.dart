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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    print('EmailTextField - isDarkMode: $isDarkMode'); // Debug

    return TextField(
      controller: controller,
      style: TextStyle(
        color:
            isDarkMode
                ? Colors.white
                : Colors.black87, // Chữ trắng trong Dark Mode
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      enabled: enable,
      decoration: InputDecoration(
        hintText: useLabelAsFixed ? null : labelText,
        hintStyle: TextStyle(
          color:
              isDarkMode
                  ? Colors.white70
                  : Colors.black54, // Gợi ý trắng nhạt trong Dark Mode
        ),
        suffixIcon: suffixIcon,
        border:
            border ??
            UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
            ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
        ),
        focusedBorder:
            focusedBorder ??
            UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
        contentPadding:
            contentPadding ??
            const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        filled: true,
        fillColor:
            isDarkMode
                ? Colors.grey[800]
                : Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}
