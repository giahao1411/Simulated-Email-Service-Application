import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final surface = theme.colorScheme.surface;
    showDialog<void>(
      context: context,
      builder:
          (context) => Theme(
            data: theme.copyWith(
              dialogTheme: DialogTheme(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
            child: AlertDialog(
              backgroundColor: surface,
              title: Text(
                'Tùy chọn nhãn',
                style: TextStyle(
                  color: onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.edit,
                      color: onSurface.withOpacity(0.7),
                    ),
                    title: Text(
                      'Đổi tên',
                      style: TextStyle(color: onSurface.withOpacity(0.7)),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onRename(label);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.delete,
                      color: onSurface.withOpacity(0.7),
                    ),
                    title: Text(
                      'Xóa',
                      style: TextStyle(color: onSurface.withOpacity(0.7)),
                    ),
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
                      child: Text('Hủy', style: TextStyle(color: onSurface)),
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

  // Hiển thị dialog đổi tên nhãn
  static void showRenameLabelDialog(
    BuildContext context, {
    required String oldLabel,
    required RenameLabelCallback onRename,
    required VoidCallback onLoadLabels,
  }) {
    final controller = TextEditingController(text: oldLabel);

    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final surface = theme.colorScheme.surface;

    showDialog<void>(
      context: context,
      builder:
          (context) => Theme(
            data: theme.copyWith(
              dialogTheme: DialogTheme(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
            child: AlertDialog(
              backgroundColor: surface,
              title: Text(
                'Đổi tên nhãn',
                style: TextStyle(
                  color: onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Nhập tên mới',
                  hintStyle: TextStyle(color: onSurface.withOpacity(0.5)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: onSurface.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.colorScheme.error,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                style: TextStyle(color: onSurface.withOpacity(0.7)),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Hủy', style: TextStyle(color: onSurface)),
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
                      child: Text(
                        'Lưu',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
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

  // Hiển thị dialog tạo nhãn mới
  static void showCreateLabelDialog(
    BuildContext context, {
    required LabelActionCallback onCreate,
    required VoidCallback onLoadLabels,
  }) {
    final controller = TextEditingController();

    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final surface = theme.colorScheme.surface;

    showDialog<void>(
      context: context,
      builder:
          (context) => Theme(
            data: theme.copyWith(
              dialogTheme: DialogTheme(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
            child: AlertDialog(
              backgroundColor: surface,
              title: Text(
                'Tạo nhãn mới',
                style: TextStyle(
                  color: onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Nhập tên nhãn',
                  hintStyle: TextStyle(color: onSurface.withOpacity(0.5)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: onSurface.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.colorScheme.error,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                style: TextStyle(color: onSurface.withOpacity(0.7)),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Hủy', style: TextStyle(color: onSurface)),
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
                      child: Text(
                        'Tạo',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
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
