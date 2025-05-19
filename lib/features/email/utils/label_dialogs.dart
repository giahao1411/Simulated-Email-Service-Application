import 'package:flutter/material.dart';

typedef LabelActionCallback = Future<bool> Function(String);
typedef RenameLabelCallback = Future<bool> Function(String, String);

class LabelDialogs {
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // Hiển thị dialog tùy chọn nhãn (Đổi tên, Xóa)
  static void showLabelOptions(
    BuildContext context, {
    required String label,
    required LabelActionCallback onDelete,
    required ValueChanged<String> onRename,
    required VoidCallback onLoadLabels,
  }) {
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
              backgroundColor: Colors.grey[800],
              title: const Text(
                'Tùy chọn nhãn',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit, color: Colors.white70),
                    title: const Text(
                      'Đổi tên',
                      style: TextStyle(color: Colors.white70),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onRename(label);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.white70),
                    title: const Text(
                      'Xóa',
                      style: TextStyle(color: Colors.white70),
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
                      child: const Text(
                        'Hủy',
                        style: TextStyle(color: Colors.white),
                      ),
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
    showDialog(
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
              backgroundColor: Colors.grey[800],
              title: const Text(
                'Đổi tên nhãn',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Nhập tên mới',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                style: const TextStyle(color: Colors.white70),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(color: Colors.white),
                      ),
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
                      child: const Text(
                        'Lưu',
                        style: TextStyle(color: Colors.red),
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
    showDialog(
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
              backgroundColor: Colors.grey[800],
              title: const Text(
                'Tạo nhãn mới',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Nhập tên nhãn',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                style: const TextStyle(color: Colors.white70),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(color: Colors.white),
                      ),
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
                      child: const Text(
                        'Tạo',
                        style: TextStyle(color: Colors.red),
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
