import 'package:email_application/features/email/controllers/settings_controller.dart';
import 'package:email_application/features/email/models/user_profile.dart';
import 'package:email_application/features/email/providers/theme_manage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileField extends StatelessWidget {
  const ProfileField({
    required this.controller,
    required this.user,
    required this.onDateSelected,
    super.key,
  });
  final SettingsController controller;
  final UserProfile user;
  final VoidCallback onDateSelected;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeManage>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Column(
      children: [
        ListTile(
          title: const Text('Email'),
          subtitle: Text(
            user.email ?? 'Chưa có email',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        ListTile(
          title: const Text('Số điện thoại'),
          subtitle: Text(
            user.phoneNumber.isNotEmpty == true
                ? user.phoneNumber
                : 'Chưa có số điện thoại',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextField(
            controller: controller.dateOfBirthController,
            decoration: InputDecoration(
              labelText: 'Ngày sinh',
              labelStyle: const TextStyle(fontSize: 16, color: Colors.grey),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: isDarkMode ? Colors.white70 : Colors.grey[700],
                ),
                onPressed: onDateSelected,
              ),
            ),
            readOnly: true,
            style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextField(
            controller: controller.firstNameController,
            decoration: const InputDecoration(
              labelText: 'Họ',
              labelStyle: TextStyle(fontSize: 16, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextField(
            controller: controller.lastNameController,
            decoration: const InputDecoration(
              labelText: 'Tên',
              labelStyle: TextStyle(fontSize: 16, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
