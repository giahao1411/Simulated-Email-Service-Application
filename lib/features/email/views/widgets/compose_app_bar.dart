import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/features/email/controllers/draft_service.dart';
import 'package:email_application/features/email/providers/compose_state.dart';
import 'package:email_application/features/email/providers/theme_manage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ComposeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ComposeAppBar({
    required this.onSendEmail,
    required this.onBack,
    required this.onToggleTextEditor,
    this.draftId,
    super.key,
  });

  final VoidCallback onSendEmail;
  final Future<bool> Function() onBack;
  final VoidCallback onToggleTextEditor;
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
            Icons.text_format,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: onToggleTextEditor,
          tooltip: 'Advanced text editing',
        ),
        // Cập nhật phần onPressed của IconButton attachment
        IconButton(
          icon: Icon(
            Icons.attachment,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () async {
            try {
              final result = await FilePicker.platform.pickFiles(
                allowMultiple: false,
                type: FileType.any,
                allowedExtensions: null,
                withData: true, // Quan trọng để có thể đọc bytes
              );

              if (result != null && result.files.isNotEmpty) {
                final file = result.files.first;

                // Kiểm tra kích thước file (giới hạn 25MB)
                if (file.size > 25 * 1024 * 1024) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'File quá lớn! Vui lòng chọn file nhỏ hơn 25MB',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  return;
                }

                // Set file vào state
                Provider.of<ComposeState>(
                  context,
                  listen: false,
                ).setSelectedFile(file);

                AppFunctions.debugPrint(
                  'Selected file: ${file.name} (${file.size} bytes)',
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã đính kèm: ${file.name}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                AppFunctions.debugPrint('No file selected');
              }
            } catch (e) {
              AppFunctions.debugPrint('Error picking file: $e');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lỗi khi chọn file. Vui lòng thử lại!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          tooltip: 'Attach file',
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(
            Icons.send,
            size: 18,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: onSendEmail,
          tooltip: 'Send email',
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
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                if (draftId != null) {
                  await DraftService().deleteDraft(draftId);
                }
                if (context.mounted) {
                  Provider.of<ComposeState>(
                    context,
                    listen: false,
                  ).clearSelectedFile();
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pop();
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
