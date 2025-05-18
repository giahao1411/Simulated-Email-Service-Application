import 'dart:io';

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
                          as ImageProvider
                      : FileImage(File(controller.avatarImagePath!))
                          as ImageProvider)
                  : null,
          child:
              controller.avatarImagePath == null ||
                      (controller.avatarImagePath!.startsWith('http'))
                  ? ClipOval(
                    child: Image.network(
                      controller.avatarImagePath!,
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) {
                        print('Lỗi tải ảnh: $error');
                        return Text(
                          controller.userProfile?.firstName?.isNotEmpty == true
                              ? controller.userProfile!.firstName![0]
                              : (controller.userProfile?.lastName ?? '')
                                  .isNotEmpty
                              ? controller.userProfile!.lastName![0]
                              : '?',
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  )
                  : Text(
                    controller.userProfile?.firstName?.isNotEmpty == true
                        ? controller.userProfile!.firstName![0]
                        : (controller.userProfile?.lastName ?? '').isNotEmpty
                        ? controller.userProfile!.lastName![0]
                        : '?',
                    style: const TextStyle(fontSize: 40, color: Colors.white),
                  ),
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
