import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/features/email/providers/theme_manage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmailTextField extends StatelessWidget {
  const EmailTextField({
    required this.controller,
    required this.labelText,
    this.suffixIcon,
    this.maxLines,
    this.keyboardType,
    this.enable = true,
    this.useLabelAsFixed = false,
    this.focusedBorderColor,
    this.stripHtml = false,
    super.key,
  });

  final TextEditingController controller;
  final String labelText;
  final Widget? suffixIcon;
  final int? maxLines;
  final TextInputType? keyboardType;
  final bool enable;
  final bool useLabelAsFixed;
  final Color? focusedBorderColor;
  final bool stripHtml;

  String _stripHtmlTags(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeManage>(context);
    final isDarkMode = themeProvider.isDarkMode;
    AppFunctions.debugPrint('EmailTextField - isDarkMode: $isDarkMode');

    final hintColor = isDarkMode ? Colors.white70 : Colors.grey[600];

    TextEditingController? displayController;
    if (stripHtml) {
      displayController = TextEditingController(
        text: _stripHtmlTags(controller.text),
      );

      controller.addListener(() {
        final plainText = _stripHtmlTags(controller.text);
        if (displayController!.text != plainText) {
          displayController.text = plainText;
        }
      });
    }

    return TextField(
      controller: displayController ?? controller,
      style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
      textAlign: TextAlign.left,
      textAlignVertical: TextAlignVertical.center,
      maxLines: maxLines ?? 1,
      keyboardType: keyboardType,
      enabled: enable,
      decoration: InputDecoration(
        hintText: useLabelAsFixed ? null : labelText,
        hintStyle: TextStyle(color: hintColor),
        suffixIcon: suffixIcon,
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[900] : Colors.white,
      ),
      onChanged:
          stripHtml
              ? (value) {
                controller.text = value;
              }
              : null,
    );
  }
}
