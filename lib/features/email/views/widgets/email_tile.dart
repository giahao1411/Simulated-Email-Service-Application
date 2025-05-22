import 'package:email_application/core/constants/app_strings.dart';
import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/utils/date_format.dart';
import 'package:flutter/material.dart';

class EmailTile extends StatelessWidget {
  const EmailTile({
    required this.email,
    required this.index,
    required this.emailService,
    required this.currentCategory,
    this.onStarToggled,
    this.onTap,
    super.key,
  });

  final Email email;
  final int index;
  final EmailService emailService;
  final String currentCategory;
  final VoidCallback? onStarToggled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget senderNameWidget;
    if (currentCategory == AppStrings.drafts) {
      senderNameWidget = Text(
        email.to.isNotEmpty ? email.to.join(', ') : 'Không có người nhận',
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: email.read ? FontWeight.normal : FontWeight.bold,
        ),
      );
    } else {
      senderNameWidget = Text(
        email.from,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: email.read ? FontWeight.normal : FontWeight.bold,
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  'https://picsum.photos/250?image=$index',
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
                      Expanded(child: senderNameWidget),
                      Text(
                        DateFormat.formatTimestamp(email.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email.subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight:
                          email.read ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          email.body,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      SizedBox(
                        width: 22,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              email.starred ? Icons.star : Icons.star_border,
                              color:
                                  email.starred
                                      ? Colors.amber
                                      : Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.6),
                              size: 25,
                            ),
                            onPressed: () async {
                              try {
                                await emailService.toggleStar(
                                  email.id,
                                  email.starred,
                                );
                                onStarToggled?.call();
                              } on Exception catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Lỗi: $e')),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
