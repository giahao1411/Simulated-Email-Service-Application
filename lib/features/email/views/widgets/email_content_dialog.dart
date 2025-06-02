import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class EmailContentDialog extends StatelessWidget {
  const EmailContentDialog({
    required this.fullBody,
    required this.onSurface70,
    super.key,
  });

  final String fullBody;
  final Color onSurface70;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chi tiết nội dung'),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.6,
        child: SingleChildScrollView(
          child: Html(
            data: fullBody,
            style: {
              'body': Style(fontSize: FontSize(16), color: onSurface70),
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
