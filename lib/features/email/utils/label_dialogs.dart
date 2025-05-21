import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_application/features/email/providers/theme_manage.dart';

typedef LabelActionCallback = Future<bool> Function(String);
typedef RenameLabelCallback = Future<bool> Function(String, String);

class LabelDialogs {
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static void showLabelOptions(
    BuildContext context, {
    required String label,
    required LabelActionCallback onDelete,
    required ValueChanged<String> onRename,
    required VoidCallback onLoadLabels,
  }) {
    final themeProvider = Provider.of<ThemeManage>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final backgroundColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final iconColor = isDarkMode ? Colors.white70 : Colors.black54;
    final actionColor = Theme.of(context).colorScheme.primary;

    showDialog<void>(
      context: context,
      builder:
          (context) => Theme(
            data: Theme.of(context).copyWith(
              dialogTheme: DialogTheme(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
            child: AlertDialog(
              backgroundColor: backgroundColor,
              title: Text(
                'Tùy chọn nhãn',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.edit, color: iconColor),
                    title: Text('Đổi tên', style: TextStyle(color: textColor)),
                    onTap: () {
                      Navigator.pop(context);
                      onRename(label);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.delete, color: iconColor),
                    title: Text('Xóa', style: TextStyle(color: textColor)),
                    onTap: () async {
                      Navigator.pop(context);
                      final success = await onDelete(label);
                      if (success) {
                        onLoadLabels();
                      } else {
                        showSnackBar(context, 'Không thể xóa nhãn');
                      }
                    },
                  ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Hủy', style: TextStyle(color: actionColor)),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
              contentPadding: const EdgeInsets.all(16),
              actionsPadding: const EdgeInsets.only(right: 16, bottom: 8),
            ),
          ),
    );
  }

  static void showRenameLabelDialog(
    BuildContext context, {
    required String oldLabel,
    required RenameLabelCallback onRename,
    required VoidCallback onLoadLabels,
  }) {
    final controller = TextEditingController(text: oldLabel);
    final themeProvider = Provider.of<ThemeManage>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final backgroundColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final inputTextColor = isDarkMode ? Colors.white70 : Colors.black87;
    final hintTextColor = isDarkMode ? Colors.white38 : Colors.grey[600];
    final actionColor = Theme.of(context).colorScheme.primary;
    final borderColor = isDarkMode ? Colors.grey : Colors.grey[300];
    final focusedBorderColor = Theme.of(context).colorScheme.primary;

    showDialog<void>(
      context: context,
      builder:
          (context) => Theme(
            data: Theme.of(context).copyWith(
              dialogTheme: DialogTheme(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
            child: AlertDialog(
              backgroundColor: backgroundColor,
              title: Text(
                'Đổi tên nhãn',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Nhập tên mới',
                  hintStyle: TextStyle(color: hintTextColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: focusedBorderColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                style: TextStyle(color: inputTextColor),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Hủy', style: TextStyle(color: actionColor)),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        if (controller.text.isNotEmpty &&
                            controller.text != oldLabel) {
                          final success = await onRename(
                            oldLabel,
                            controller.text,
                          );
                          if (success) {
                            onLoadLabels();
                            Navigator.pop(context);
                          } else {
                            showSnackBar(
                              context,
                              'Nhãn đã tồn tại hoặc không thể đổi tên',
                            );
                          }
                        }
                      },
                      child: Text('Lưu', style: TextStyle(color: actionColor)),
                    ),
                  ],
                ),
              ],
              contentPadding: const EdgeInsets.all(16),
              actionsPadding: const EdgeInsets.only(right: 16, bottom: 8),
            ),
          ),
    );
  }

  static void showCreateLabelDialog(
    BuildContext context, {
    required LabelActionCallback onCreate,
    required VoidCallback onLoadLabels,
  }) {
    final controller = TextEditingController();
    final themeProvider = Provider.of<ThemeManage>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final backgroundColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final inputTextColor = isDarkMode ? Colors.white70 : Colors.black87;
    final hintTextColor = isDarkMode ? Colors.white38 : Colors.grey[600];
    final actionColor = Theme.of(context).colorScheme.primary;
    final borderColor = isDarkMode ? Colors.grey : Colors.grey[300];
    final focusedBorderColor = Theme.of(context).colorScheme.primary;

    showDialog<void>(
      context: context,
      builder:
          (context) => Theme(
            data: Theme.of(context).copyWith(
              dialogTheme: DialogTheme(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
            child: AlertDialog(
              backgroundColor: backgroundColor,
              title: Text(
                'Tạo nhãn mới',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Nhập tên nhãn',
                  hintStyle: TextStyle(color: hintTextColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: focusedBorderColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                style: TextStyle(color: inputTextColor),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Hủy', style: TextStyle(color: actionColor)),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        if (controller.text.isNotEmpty) {
                          final success = await onCreate(controller.text);
                          if (success) {
                            onLoadLabels();
                            Navigator.pop(context);
                          } else {
                            showSnackBar(context, 'Nhãn đã tồn tại');
                          }
                        }
                      },
                      child: Text('Tạo', style: TextStyle(color: actionColor)),
                    ),
                  ],
                ),
              ],
              contentPadding: const EdgeInsets.all(16),
              actionsPadding: const EdgeInsets.only(right: 16, bottom: 8),
            ),
          ),
    );
  }
}
