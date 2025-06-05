import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/utils/date_format.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final senderName =
        replyEmail.from.isEmpty ? '(No sender)' : replyEmail.from;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
              'https://picsum.photos/250?image=${replyEmail.id.hashCode}',
            ),
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
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        color: onSurface60,
                      ),
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
                        icon: Icon(Icons.reply, color: onSurface60, size: 20),
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
  }
}
