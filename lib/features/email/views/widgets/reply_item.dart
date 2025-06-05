import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/views/widgets/reply_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class ReplyItem extends StatelessWidget {
  const ReplyItem({
    required this.replyEmail,
    required this.onSurface60,
    required this.onSurface70,
    required this.onShowOriginalEmail,
    super.key,
  });

  final Email replyEmail;
  final Color onSurface60;
  final Color onSurface70;
  final VoidCallback onShowOriginalEmail;

  String getSummaryBody(String body) {
    final plainText = body.replaceAll(RegExp('<[^>]*>'), '').trim();
    if (plainText.isEmpty) return '(No content)';
    final quoteIndex = plainText.indexOf('On ');
    return quoteIndex != -1
        ? plainText.substring(0, quoteIndex).trim()
        : plainText.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReplyHeader(
            replyEmail: replyEmail,
            onSurface60: onSurface60,
            onSurface70: onSurface70,
            onShowOriginalEmail: onShowOriginalEmail,
          ),
          const SizedBox(height: 4),
          Html(
            data: replyEmail.body,
            style: {
              'body': Style(fontSize: FontSize(16), color: onSurface70),
              'img': Style(
                display: Display.block,
                margin: Margins.symmetric(vertical: 8),
              ),
              'p': Style(margin: Margins.only(bottom: 8)),
            },
          ),
          if (replyEmail.cc.isNotEmpty || replyEmail.bcc.isNotEmpty) ...[
            const SizedBox(height: 8),
            if (replyEmail.cc.isNotEmpty)
              Text(
                'Cc: ${replyEmail.cc.join(', ')}',
                style: TextStyle(color: onSurface70, fontSize: 14),
              ),
            if (replyEmail.bcc.isNotEmpty)
              Text(
                'Bcc: ${replyEmail.bcc.join(', ')}',
                style: TextStyle(color: onSurface70, fontSize: 14),
              ),
          ],
        ],
      ),
    );
  }
}
