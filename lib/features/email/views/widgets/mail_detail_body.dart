import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/utils/date_format.dart';
import 'package:flutter/material.dart';

class MailDetailBody extends StatefulWidget {
  MailDetailBody({required this.email, this.onRefresh, super.key});

  final Email email;
  final VoidCallback? onRefresh;

  final EmailService emailService = EmailService();

  @override
  State<MailDetailBody> createState() => _MailDetailBodyState();
}

class _MailDetailBodyState extends State<MailDetailBody> {
  late Email email;
  final EmailService emailService = EmailService();

  @override
  void initState() {
    super.initState();
    email = widget.email;
  }

  Future<int> countUnreadMails() {
    return emailService.countUnreadEmails();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final onSurface60 = onSurface.withOpacity(0.6);
    final onSurface70 = onSurface.withOpacity(0.7);
    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // mail subject
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      email.subject,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: onSurface,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        email.starred ? Icons.star : Icons.star_border,
                        color: email.starred ? Colors.amber : onSurface60,
                        size: 25,
                      ),
                      onPressed: () async {
                        await emailService.toggleStar(email.id, email.starred);
                        setState(() {
                          email = email.copyWith(starred: !email.starred);
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // sender information
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://via.placeholder.com/40',
                    ),
                  ),
                  title: Row(
                    children: [
                      FutureBuilder<String>(
                        future: emailService.getUserFullNameByEmail(email.from),
                        builder: (context, snapshot) {
                          final displayName =
                              (snapshot.connectionState ==
                                          ConnectionState.done &&
                                      snapshot.hasData)
                                  ? snapshot.data!
                                  : '';
                          return Text(
                            displayName,
                            style: TextStyle(color: onSurface),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat.formatTimestamp(email.timestamp),
                        style: TextStyle(color: onSurface70, fontSize: 12),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    'to bcc: ${email.bcc}',
                    style: TextStyle(color: onSurface70),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.reply, color: onSurface60),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.more_horiz, color: onSurface60),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  onTap: () {},
                ),

                // mail body
                Text(
                  email.body,
                  style: TextStyle(fontSize: 16, color: onSurface70),
                ),
              ],
            ),
          ),

          // utils/icons
          Container(
            padding: const EdgeInsets.all(8),
            color: theme.colorScheme.surface,
            child: Column(
              children: [
                OverflowBar(
                  alignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: onSurface60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.reply, color: onSurface60),
                          const SizedBox(width: 4),
                          Text('Reply', style: TextStyle(color: onSurface60)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: onSurface60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.forward, color: onSurface60),
                          const SizedBox(width: 4),
                          Text('Forward', style: TextStyle(color: onSurface60)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [_unreadMailRemainingIcon(onSurface)],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _unreadMailRemainingIcon(Color iconColor) {
    final iconButton = IconButton(
      icon: Icon(Icons.mail_outline, color: iconColor, size: 26),
      onPressed: () {
        Navigator.pop(context);
        widget.onRefresh?.call();
      },
    );

    return FutureBuilder<int>(
      future: countUnreadMails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return mailBadge('...', iconButton);
        }
        if (snapshot.hasError) {
          return mailBadge('Error', iconButton);
        }
        if (snapshot.data != null && snapshot.data! > 0) {
          return mailBadge(snapshot.data.toString(), iconButton);
        }
        return iconButton;
      },
    );
  }

  Widget mailBadge(String text, IconButton iconButton) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        iconButton,
        Positioned(
          right: 8,
          top: 8,
          child: Badge(
            label: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            child: const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
