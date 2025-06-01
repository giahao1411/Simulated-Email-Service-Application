import 'package:email_application/features/email/providers/theme_manage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PickerBottomSheet {
  static void showPicker({
    required BuildContext context,
    required String title,
    required List<String> options,
    required String? selectedValue,
    required void Function(String?) onSelect,
    required String Function(String) getDisplayName,
  }) {
    if (options.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không có dữ liệu cho $title')));
      return;
    }

    final themeProvider = Provider.of<ThemeManage>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final backgroundColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final iconColor = isDarkMode ? Colors.white70 : Colors.black54;
    final actionColor = Theme.of(context).colorScheme.primary;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: backgroundColor,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: iconColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Divider(
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
                ),
                ...options.map(
                  (item) => ListTile(
                    title: Text(
                      getDisplayName(item),
                      style: TextStyle(color: textColor),
                    ),
                    trailing:
                        selectedValue == item
                            ? Icon(Icons.check, color: actionColor)
                            : null,
                    onTap: () {
                      onSelect(selectedValue == item ? null : item);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showAttachmentPicker({
    required BuildContext context,
    required bool? hasAttachments,
    required void Function(bool?) onSelect,
  }) {
    final themeProvider = Provider.of<ThemeManage>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final backgroundColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final iconColor = isDarkMode ? Colors.white70 : Colors.black54;
    final actionColor = Theme.of(context).colorScheme.primary;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: backgroundColor,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tệp đính kèm',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: iconColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Divider(
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
                ),
                ListTile(
                  title: Text(
                    'Có tệp đính kèm',
                    style: TextStyle(color: textColor),
                  ),
                  trailing:
                      hasAttachments == false
                          ? Icon(Icons.check, color: actionColor)
                          : null,
                  onTap: () {
                    onSelect(hasAttachments == true ? null : true);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text(
                    'Không có tệp đính kèm',
                    style: TextStyle(color: textColor),
                  ),
                  trailing:
                      hasAttachments == false
                          ? Icon(Icons.check, color: actionColor)
                          : null,
                  onTap: () {
                    onSelect(hasAttachments == false ? null : false);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
