import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/core/constants/app_strings.dart';
import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/controllers/label_controller.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:flutter/material.dart';

class MailDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MailDetailAppBar({
    required this.email,
    required this.emailService,
    this.onRefresh,
    this.refreshStream,
    this.onCategoryChanged,
    super.key,
  });

  final Email email;
  final EmailService emailService;
  final VoidCallback? onRefresh;
  final VoidCallback? refreshStream;
  final void Function(String)? onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final LabelController labelController = LabelController();

    return AppBar(
      actionsPadding: const EdgeInsets.only(left: 16, right: 8),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
        onPressed: () {
          onRefresh?.call();
          refreshStream?.call();
          Navigator.pop(context);
        },
      ),
      backgroundColor:
          theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
      actions: [
        IconButton(
          icon: Icon(
            Icons.label_outline,
            color: theme.colorScheme.onSurface,
          ), // Thay icon thùng rác bằng icon nhãn
          onPressed: () async {
            await _showLabelsDialog(context, labelController);
          },
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(
            Icons.mark_email_unread_outlined,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () async {
            try {
              await emailService.toggleRead(email.id, email.read);
              AppFunctions.debugPrint('Trạng thái read: ${!email.read}');
              onRefresh?.call();
              refreshStream?.call();
              Navigator.pop(context);
            } catch (e) {
              AppFunctions.debugPrint('Lỗi khi chuyển trạng thái đã đọc: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lỗi khi chuyển trạng thái đã đọc: $e')),
              );
            }
          },
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_horiz, color: theme.colorScheme.onSurface),
          onSelected: (String value) async {
            try {
              switch (value) {
                case 'hide':
                  await emailService.markAsHidden(email.id, email.hidden);
                  AppFunctions.debugPrint(
                    'Trạng thái hidden: ${!email.hidden}',
                  );
                  onRefresh?.call();
                  refreshStream?.call();
                  onCategoryChanged?.call(AppStrings.hidden);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã tạm ẩn email')),
                  );
                  break;
                case 'labels':
                  await _showLabelsDialog(context, labelController);
                  break;
                case 'important':
                  await emailService.markAsImportant(email.id, email.important);
                  AppFunctions.debugPrint(
                    'Trạng thái important: ${!email.important}',
                  );
                  onRefresh?.call();
                  refreshStream?.call();
                  onCategoryChanged?.call(AppStrings.important);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        email.important
                            ? 'Đã bỏ đánh dấu quan trọng'
                            : 'Đã đánh dấu quan trọng',
                      ),
                    ),
                  );
                  break;
                case 'spam':
                  await emailService.markAsSpam(email.id, email.spam);
                  AppFunctions.debugPrint('Trạng thái spam: ${!email.spam}');
                  onRefresh?.call();
                  refreshStream?.call();
                  onCategoryChanged?.call(AppStrings.spam);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã báo cáo thư rác')),
                  );
                  break;
                case 'cancel':
                  Navigator.pop(context);
                  break;
              }
            } catch (e) {
              AppFunctions.debugPrint('Lỗi khi thực hiện hành động $value: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lỗi khi thực hiện hành động: $e')),
              );
            }
          },
          itemBuilder:
              (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'hide',
                  child: Text('Tạm ẩn'),
                ),
                const PopupMenuItem<String>(
                  value: 'labels',
                  child: Text('Nhãn'),
                ),
                PopupMenuItem<String>(
                  value: 'important',
                  child: Text(
                    email.important
                        ? 'Bỏ đánh dấu quan trọng'
                        : 'Đánh dấu là quan trọng',
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'spam',
                  child: Text('Báo cáo thư rác'),
                ),
                const PopupMenuItem<String>(
                  value: 'cancel',
                  child: Text('Hủy'),
                ),
              ],
        ),
      ],
    );
  }

  Future<void> _showLabelsDialog(
    BuildContext context,
    LabelController labelController,
  ) async {
    final labels = await labelController.loadLabels();
    // Tạo một bản sao của danh sách nhãn hiện tại của email
    List<String> selectedLabels = List.from(email.labels ?? []);

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: const Text('Quản lý nhãn'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (labels.isNotEmpty)
                        Column(
                          children:
                              labels.map((label) {
                                final isSelected = selectedLabels.contains(
                                  label,
                                );
                                return CheckboxListTile(
                                  title: Text(label),
                                  secondary: const Icon(Icons.label_outline),
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        if (!selectedLabels.contains(label)) {
                                          selectedLabels.add(label);
                                        }
                                      } else {
                                        selectedLabels.remove(label);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Không có nhãn nào'),
                        ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Hủy'),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        // Cập nhật danh sách nhãn trong Firestore
                        await emailService.updateEmailStatus(email.id, {
                          'labels': selectedLabels,
                        });
                        AppFunctions.debugPrint(
                          'Đã cập nhật nhãn: $selectedLabels',
                        );
                        onRefresh?.call();
                        refreshStream?.call();
                        Navigator.pop(dialogContext);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã cập nhật nhãn')),
                          );
                        }
                        // Nếu có nhãn được chọn, chuyển đến danh mục của nhãn đầu tiên
                        if (selectedLabels.isNotEmpty) {
                          onCategoryChanged?.call(selectedLabels.first);
                        }
                      } catch (e) {
                        AppFunctions.debugPrint('Lỗi khi cập nhật nhãn: $e');
                        if (dialogContext.mounted) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                              content: Text('Lỗi khi cập nhật nhãn: $e'),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Lưu'),
                  ),
                ],
              );
            },
          ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
