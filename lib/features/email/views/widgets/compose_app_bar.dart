import 'package:flutter/material.dart';

class ComposeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ComposeAppBar({
    required this.onSaveDraft,
    required this.onSendEmail,
    super.key,
  });

  final VoidCallback onSaveDraft;
  final VoidCallback onSendEmail;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white70),
        onPressed: () => Navigator.pop(context),
      ),
      backgroundColor: Colors.grey[900],
      actions: [
        IconButton(
          icon: const Icon(Icons.attachment, color: Colors.white70),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.send, size: 18, color: Colors.white70),
          onPressed: onSendEmail,
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz, color: Colors.white70),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
