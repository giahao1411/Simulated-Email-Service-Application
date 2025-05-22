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
        icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
        onPressed: () => Navigator.pop(context),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      actions: [
        IconButton(
          icon: Icon(
            Icons.drafts,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(
            Icons.send,
            size: 18,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: onSendEmail,
        ),
        IconButton(
          icon: Icon(
            Icons.more_horiz,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
