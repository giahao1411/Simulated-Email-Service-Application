import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/features/email/controllers/draft_service.dart';
import 'package:email_application/features/email/providers/theme_manage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ComposeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ComposeAppBar({
    required this.onSendEmail,
    required this.onBack,
    this.draftId,
    super.key,
  });

  final VoidCallback onSendEmail;
  final Future<bool> Function() onBack;
  final String? draftId;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
        onPressed: () async {
          if (await onBack() && context.mounted) {
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
      onSelected: (String value) async {
        if (value == 'discard') {
          showDiscardConfirmationDialog(context, draftId);
        } else if (value == 'schedule-send') {
          // Handle schedule send action
          AppFunctions.debugPrint('Schedule send action selected');
          // Implement your schedule send logic here
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

  void showDiscardConfirmationDialog(BuildContext context, String? draftId) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác nhận bỏ nháp'),
          content: const Text('Bạn có chắc chắn muốn bỏ nháp này không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // close dialog
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                if (draftId != null) {
                  await DraftService().deleteDraft(draftId);
                }
                if (context.mounted) {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pop(); // on composing
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nháp đã được bỏ')),
                  );
                }
              },
              child: const Text('Bỏ'),
            ),
          ],
        );
      },
    );
  }
}
