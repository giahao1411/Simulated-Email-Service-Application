import 'dart:io';
import 'dart:math';

import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/features/email/controllers/settings_controller.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.controller,
    required this.isLoading,
    super.key,
    this.onPickImage,
  });
  final SettingsController controller;
  final bool isLoading;
  final VoidCallback? onPickImage;

  String _getProfileInitial() {
    final firstName = controller.userProfile?.firstName;
    final lastName = controller.userProfile?.lastName;
    if (firstName != null && firstName.isNotEmpty) {
      return firstName[0].toUpperCase();
    } else if (lastName != null && lastName.isNotEmpty) {
      return lastName[0].toUpperCase();
    } else {
      return '?';
    }
  }

  Color _getRandomColor() {
    return Color(0xFF000000 + (Random().nextInt(0xFFFFFF))).withOpacity(1);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage:
              controller.avatarImagePath != null
                  ? (controller.avatarImagePath!.startsWith('http')
                      ? NetworkImage(controller.avatarImagePath!)
                      : FileImage(File(controller.avatarImagePath!)))
                  : null,
          backgroundColor:
              controller.avatarImagePath == null ? _getRandomColor() : null,
          child:
              controller.avatarImagePath == null
                  ? Text(
                    _getProfileInitial(),
                    style: const TextStyle(fontSize: 40, color: Colors.white),
                  )
                  : (controller.avatarImagePath!.startsWith('http')
                      ? ClipOval(
                        child: Image.network(
                          controller.avatarImagePath!,
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                          errorBuilder: (context, error, stackTrace) {
                            AppFunctions.debugPrint('Lỗi tải ảnh: $error');
                            return Text(
                              _getProfileInitial(),
                              style: const TextStyle(
                                fontSize: 40,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      )
                      : null),
        ),
        IconButton(
          icon: const Icon(Icons.camera_alt, color: Colors.white),
          onPressed: isLoading ? null : () => controller.pickImage(context),
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}
