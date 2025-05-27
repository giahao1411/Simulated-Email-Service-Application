import 'package:email_application/core/constants/app_strings.dart';
import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/models/email_state.dart';
import 'package:email_application/features/email/utils/date_format.dart';
import 'package:email_application/features/email/utils/email_recipients.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MailDetailBody extends StatefulWidget {
  MailDetailBody({
    required this.email,
    required this.state,
    this.onRefresh,
    this.markMailAsRead,
    super.key,
  });

  final Email email;
  final EmailState state;
  final VoidCallback? onRefresh;
  final VoidCallback? markMailAsRead;

  final EmailService emailService = EmailService();

  @override
  State<MailDetailBody> createState() => _MailDetailBodyState();
}

class _MailDetailBodyState extends State<MailDetailBody> {
  late Email email;
  late EmailState state;
  final EmailService emailService = EmailService();
  bool isShowSendingDetail = false;

  @override
  void initState() {
    super.initState();
    email = widget.email;
    state = widget.state;
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
      padding: const EdgeInsets.only(left: 16, right: 8),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // mail subject
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        email.subject,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        state.starred ? Icons.star : Icons.star_border,
                        color: state.starred ? Colors.amber : onSurface60,
                        size: 25,
                      ),
                      onPressed: () async {
                        await emailService.toggleStar(email.id, state.starred);
                        widget.onRefresh?.call();
                      },
                    ),
                  ],
                ),

                // sender information
                ListTile(
                  contentPadding: const EdgeInsets.only(right: -16),
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
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [buildSendingDetail(email, onSurface70)],
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

                // sender container details
                if (isShowSendingDetail)
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(top: 4, bottom: 20, right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: onSurface60.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: buildSendingDetailContainer(email, onSurface70),
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
                    if (email.cc.isNotEmpty)
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
                            Icon(Icons.reply_all, color: onSurface60),
                            const SizedBox(width: 4),
                            Text(
                              'Reply all',
                              style: TextStyle(color: onSurface60),
                            ),
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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [SizedBox.shrink()],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSendingDetail(Email email, Color onSurface70) {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    final recipientText = EmailRecipient.formatRecipient(
      email.to,
      email.bcc,
      currentUserEmail,
    );

    return GestureDetector(
      onTap: () {
        setState(() {
          isShowSendingDetail = !isShowSendingDetail;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Text(
              recipientText,
              style: TextStyle(color: onSurface70),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isShowSendingDetail ? Icons.expand_less : Icons.expand_more,
            color: onSurface70,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget buildSendingDetailContainer(Email email, Color onSurface70) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 60,
              child: Text(
                AppStrings.from,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: onSurface70,
                ),
              ),
            ),
            Expanded(
              child: Text(
                email.from,
                style: TextStyle(color: onSurface70),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (email.to.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      AppStrings.to,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: onSurface70,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 1000,
                      runSpacing: 2,
                      children:
                          email.to
                              .map(
                                (emailAddress) => Text(
                                  emailAddress,
                                  style: TextStyle(color: onSurface70),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        if (email.cc.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      AppStrings.cc,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: onSurface70,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 1000,
                      runSpacing: 2,
                      children:
                          email.cc
                              .map(
                                (emailAddress) => Text(
                                  emailAddress,
                                  style: TextStyle(color: onSurface70),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        if (email.bcc.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      AppStrings.bcc,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: onSurface70,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 1000,
                      runSpacing: 2,
                      children:
                          email.bcc
                              .map(
                                (emailAddress) => Text(
                                  emailAddress,
                                  style: TextStyle(color: onSurface70),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 60,
              child: Text(
                AppStrings.date,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: onSurface70,
                ),
              ),
            ),
            Expanded(
              child: Text(
                DateFormat.formatDetailedTimestamp(email.timestamp),
                style: TextStyle(color: onSurface70),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
