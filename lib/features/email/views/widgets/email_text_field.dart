import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/features/email/providers/theme_manage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    this.labelStyle,
    this.focusedBorderColor,
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
  final TextStyle? labelStyle;
  final Color? focusedBorderColor;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeManage>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final colorScheme = Theme.of(context).colorScheme;
    AppFunctions.debugPrint('EmailTextField - isDarkMode: $isDarkMode');

    final borderColor = isDarkMode ? Colors.white70 : Colors.grey;
    final hintColor = isDarkMode ? Colors.white70 : Colors.grey[600];

    return TextField(
      controller: controller,
      style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
      maxLines: maxLines,
      keyboardType: keyboardType,
      enabled: enable,
      decoration: InputDecoration(
        labelText: null,
        hintText: useLabelAsFixed ? null : labelText,
        hintStyle: TextStyle(color: hintColor),
        suffixIcon: suffixIcon,
        border:
            border ??
            UnderlineInputBorder(borderSide: BorderSide(color: borderColor)),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder:
            focusedBorder ??
            UnderlineInputBorder(
              borderSide: BorderSide(
                color: focusedBorderColor ?? colorScheme.primary,
                width: 2,
              ),
            ),
        contentPadding:
            contentPadding ??
            const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[900] : Colors.white,
      ),
    );
  }
}
