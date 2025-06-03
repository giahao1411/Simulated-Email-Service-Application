import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class EmailContentDialog extends StatelessWidget {
  const EmailContentDialog({
    required this.fullBody,
    required this.isDarkMode,
    super.key,
  });

  final String fullBody;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor:
          isDarkMode
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).colorScheme.primaryContainer,
      title: const Text('Chi tiết nội dung'),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.6,
        child: SingleChildScrollView(
          child: Html(
            data: fullBody,
            style: {
              'body': Style(
                fontSize: FontSize(16),
                color: isDarkMode ? Colors.white70 : Colors.grey[900],
              ),
              'img': Style(
                display: Display.block,
                margin: Margins.symmetric(vertical: 8),
              ),
              'p': Style(margin: Margins.only(bottom: 8)),
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}
