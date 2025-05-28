import 'package:email_application/features/email/providers/theme_manage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ComposeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ComposeAppBar({
    required this.onSaveDraft,
    required this.onSendEmail,
    required this.onBack,
    super.key,
  });

  final VoidCallback onSaveDraft;
  final VoidCallback onSendEmail;
  final Future<bool> Function() onBack;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
        onPressed: () async {
          if (await onBack()) {
            Navigator.pop(context);
          }
        },
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      actions: [
        IconButton(
          icon: Icon(
            Icons.attachment,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(
            Icons.send,
            size: 18,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: onSendEmail,
        ),
        popUpMenuButton(context),
      ],
    );
  }

  Widget popUpMenuButton(BuildContext context) {
    final themeProvider = Provider.of<ThemeManage>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final textIconTheme = isDarkMode ? Colors.white70 : Colors.grey[800];

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz, color: textIconTheme),
      offset: const Offset(0, 40),
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      onSelected: (String value) {
        if (value == 'discard') {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đã bỏ nháp!')));
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pop(context);
          });
        }
      },
      itemBuilder:
          (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'discard',
              child: ListTile(
                leading: Text(
                  'Discard',
                  style: TextStyle(fontSize: 16, color: textIconTheme),
                ),
                trailing: Icon(Icons.delete, color: textIconTheme),
              ),
            ),
            PopupMenuItem<String>(
              value: 'schedule-send',
              child: ListTile(
                leading: Text(
                  'Schedule send',
                  style: TextStyle(fontSize: 16, color: textIconTheme),
                ),
                trailing: Icon(
                  Icons.schedule_send_outlined,
                  color: textIconTheme,
                ),
              ),
            ),
          ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
