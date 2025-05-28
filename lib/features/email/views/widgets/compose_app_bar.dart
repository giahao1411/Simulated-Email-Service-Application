import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/core/constants/app_strings.dart';
import 'package:email_application/features/email/controllers/draft_service.dart';
import 'package:email_application/features/email/providers/theme_manage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ComposeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ComposeAppBar({
    required this.onSendEmail,
    required this.onBack,
    required this.draftId,
    super.key,
  });

  final VoidCallback onSendEmail;
  final Future<bool> Function() onBack;
  final String draftId;

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
    final draftService = DraftService();

    final themeProvider = Provider.of<ThemeManage>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final textIconTheme = isDarkMode ? Colors.white70 : Colors.grey[800];

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz, color: textIconTheme),
      offset: const Offset(0, 40),
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      onSelected: (String value) async {
        if (value == 'discard') {
          try {
            await draftService.deleteDraft(draftId);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('${AppStrings.drafts} đã được bỏ'),
                ),
              );
            }
          } on Exception catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Bỏ nháp thất bại: $e')));
            }
          }
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
}
