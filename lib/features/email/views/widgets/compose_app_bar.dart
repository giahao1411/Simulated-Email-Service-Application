import 'package:email_application/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

class ComposeAppBar extends StatelessWidget implements PreferredSizeWidget {

  const ComposeAppBar({
    required this.onSaveDraft, required this.onSendEmail, super.key,
  });
  final VoidCallback onSaveDraft;
  final VoidCallback onSendEmail;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(AppStrings.composeEmail),
      actions: [
        IconButton(icon: const Icon(Icons.save), onPressed: onSaveDraft),
        IconButton(icon: const Icon(Icons.send), onPressed: onSendEmail),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
