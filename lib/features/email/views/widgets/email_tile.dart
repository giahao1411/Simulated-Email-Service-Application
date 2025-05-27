import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/models/email_state.dart';
import 'package:email_application/features/email/utils/date_format.dart';
import 'package:flutter/material.dart';

class EmailTile extends StatelessWidget {
  const EmailTile({
    required this.email,
    required this.state,
    required this.index,
    required this.emailService,
    required this.currentCategory,
    this.onStarToggled,
    this.onTap,
    super.key,
  });

  final Email email;
  final EmailState state;
  final int index;
  final EmailService emailService;
  final String currentCategory;
  final VoidCallback? onStarToggled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final senderNameWidget = FutureBuilder<String>(
      future: emailService.getUserFullNameByEmail(email.from),
      builder: (context, snapshot) {
        final displayName =
            snapshot.connectionState == ConnectionState.done && snapshot.hasData
                ? snapshot.data!
                : email.from;
        return Text(
          displayName,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: state.read ? FontWeight.normal : FontWeight.bold,
          ),
        );
      },
    );

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Text(
          email.from.isNotEmpty ? email.from[0].toUpperCase() : '?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: senderNameWidget),
          Text(
            DateFormat.formatTimestamp(email.timestamp),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: 12,
              fontWeight: email.read ? FontWeight.normal : FontWeight.bold,
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
                  Text(
                    email.subject.isEmpty ? '(No Subject)' : email.subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight:
                          state.read ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          email.body.isEmpty ? '(No Content)' : email.body,
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
                        height: 26,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              state.starred ? Icons.star : Icons.star_outline,
                              color:
                                  state.starred
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
                                  state.starred,
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
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(
          email.starred ? Icons.star : Icons.star_border,
          color:
              email.starred
                  ? Colors
                      .amber // Màu vàng khi đã tích
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          size: 20,
        ),
        onPressed: () async {
          try {
            await emailService.toggleStar(email.id, email.starred);
            onStarToggled?.call();
          } catch (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
          }
        },
      ),
    );
  }
}
