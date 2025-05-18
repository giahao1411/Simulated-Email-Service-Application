import 'package:email_application/features/email/controllers/settings_controller.dart';
import 'package:email_application/features/email/models/user_profile.dart';
import 'package:flutter/material.dart';

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
                icon: const Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Colors.grey,
                ),
                onPressed: onDateSelected,
              ),
            ),
            readOnly: true,
            style: const TextStyle(color: Colors.white70),
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
