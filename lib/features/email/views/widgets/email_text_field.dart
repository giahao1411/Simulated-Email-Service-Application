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

  // Hàm loại bỏ HTML tags (nếu có)
  String _stripHtmlTags(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(' ', ' ')
        .replaceAll('&', '&')
        .replaceAll('<', '<')
        .replaceAll('>', '>')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeManage>(context);
    final isDarkMode = themeProvider.isDarkMode;
    AppFunctions.debugPrint('EmailTextField - isDarkMode: $isDarkMode');

    final hintColor = isDarkMode ? Colors.white70 : Colors.grey[600];

    // Tạo một TextEditingController mới để hiển thị văn bản thô
    final displayController = TextEditingController(
      text: _stripHtmlTags(controller.text),
    );

    // Đồng bộ nội dung khi controller gốc thay đổi
    controller.addListener(() {
      final plainText = _stripHtmlTags(controller.text);
      if (displayController.text != plainText) {
        displayController.text = plainText;
      }
    });

    return TextField(
      controller: displayController,
      style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
      textAlign: TextAlign.left,
      textAlignVertical: TextAlignVertical.center,
      maxLines: maxLines ?? 1, // Đặt mặc định maxLines là 1 cho các trường ngắn
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
      onChanged: (value) {
        // Đồng bộ ngược lại controller gốc nếu người dùng chỉnh sửa
        controller.text = value;
      },
    );
  }
}
