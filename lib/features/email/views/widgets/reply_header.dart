import 'dart:io';
import 'dart:math';

import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/utils/date_format.dart';
import 'package:email_application/features/email/utils/photo_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

// Widget for the reply header, styled to match EmailTile
class ReplyHeader extends StatelessWidget {
  const ReplyHeader({
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

  String _getInitial(String senderName) {
    final parts = senderName.trim().split(' ');
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  Color _getRandomColor() {
    return Color(0xFF000000 + (Random().nextInt(0xFFFFFF))).withOpacity(1);
  }

  @override
  Widget build(BuildContext context) {
    final senderName =
        replyEmail.from.isEmpty ? '(No sender)' : replyEmail.from;

    return FutureBuilder<String>(
      future: PhotoUtil.getPhotoUrlByEmail(replyEmail.from),
      builder: (context, snapshot) {
        ImageProvider? avatarImage;
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data!.isNotEmpty) {
          avatarImage =
              snapshot.data!.startsWith('http')
                  ? NetworkImage(snapshot.data!)
                  : FileImage(File(snapshot.data!)) as ImageProvider;
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: CircleAvatar(
                radius: 20,
                backgroundImage: avatarImage,
                backgroundColor: avatarImage == null ? _getRandomColor() : null,
                child:
                    avatarImage == null
                        ? Text(
                          _getInitial(senderName),
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        )
                        : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          senderName,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontSize: 16, color: onSurface60),
                        ),
                      ),
                      Text(
                        DateFormat.formatTimestamp(replyEmail.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: onSurface60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          replyEmail.subject.isEmpty
                              ? '(Không chủ đề)'
                              : replyEmail.subject,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: onSurface60),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.reply,
                              color: onSurface60,
                              size: 20,
                            ),
                            onPressed: null,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.more_horiz,
                              color: onSurface60,
                              size: 20,
                            ),
                            onPressed: onShowOriginalEmail,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

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
