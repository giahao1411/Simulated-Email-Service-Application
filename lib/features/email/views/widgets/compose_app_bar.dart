import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';

class ComposeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSaveDraft;
  final VoidCallback onSendEmail;

  const ComposeAppBar({
    super.key,
    required this.onSaveDraft,
    required this.onSendEmail,
  });

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
