import 'package:email_application/core/constants/app_strings.dart';
import 'package:email_application/features/email/providers/theme_manage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ComposeButton extends StatelessWidget {
  const ComposeButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // Lấy trạng thái Dark Mode trực tiếp từ ThemeManage
    final isDarkMode = Provider.of<ThemeManage>(context).isDarkMode;

    // Định nghĩa màu sắc dựa trên chế độ
    final buttonColor = isDarkMode ? Colors.blue[900] : Colors.red;
    final iconTextColor = isDarkMode ? Colors.cyan[100] : Colors.pink[100];

    return Positioned(
      bottom: 66,
      right: 16,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_outlined, color: iconTextColor, size: 18),
              const SizedBox(width: 8),
              Text(
                AppStrings.composeEmail,
                style: TextStyle(color: iconTextColor, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
