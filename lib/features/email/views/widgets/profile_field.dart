import 'package:email_application/features/email/controllers/settings_controller.dart';
import 'package:email_application/features/email/models/user_profile.dart';
import 'package:flutter/material.dart';

class ProfileField extends StatelessWidget {
  const ProfileField({required this.controller, required this.user, super.key});
  final SettingsController controller;
  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('Email'),
          subtitle: Text(user.email ?? 'Chưa có email'),
        ),
        ListTile(
          title: const Text('Số điện thoại'),
          subtitle: Text(
            user.phoneNumber.isNotEmpty == true
                ? user.phoneNumber
                : 'Chưa có số điện thoại',
          ),
        ),
        ListTile(
          title: const Text('Ngày sinh'),
          subtitle: Text(
            user.dateOfBirth.toString().isNotEmpty == true
                ? user.dateOfBirth.toString().substring(0, 10)
                : 'Chưa có ngày sinh',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextField(
            controller: controller.firstNameController,
            decoration: const InputDecoration(labelText: 'Họ'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextField(
            controller: controller.lastNameController,
            decoration: const InputDecoration(labelText: 'Tên'),
          ),
        ),
      ],
    );
  }
}
