import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/models/email_state.dart';
import 'package:email_application/features/email/providers/theme_manage.dart';
import 'package:email_application/features/email/views/widgets/email_content_dialog.dart';
import 'package:email_application/features/email/views/widgets/reply_item.dart';
import 'package:email_application/features/email/views/widgets/sender_info.dart';
import 'package:email_application/features/email/views/widgets/sending_detail_container.dart';
import 'package:email_application/features/email/views/widgets/subject_row.dart';
import 'package:email_application/features/email/views/widgets/utils_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';

class MailDetailBody extends StatefulWidget {
  MailDetailBody({
    required this.email,
    required this.state,
    required this.index,
    required this.senderFullName,
    required this.sendReply,
    required this.sendReplyAll,
    this.sendForward,
    this.onRefresh,
    this.markMailAsRead,
    super.key,
  });

  final Email email;
  final EmailState state;
  final int index;
  final String senderFullName;
  final VoidCallback? onRefresh;
  final VoidCallback? markMailAsRead;
  final VoidCallback sendReply;
  final VoidCallback sendReplyAll;
  final VoidCallback? sendForward;

  final EmailService emailService = EmailService();

  @override
  State<MailDetailBody> createState() => _MailDetailBodyState();
}

class _MailDetailBodyState extends State<MailDetailBody> {
  late Email email;
  late EmailState state;
  bool isShowSendingDetail = false;

  @override
  void initState() {
    super.initState();
    email = widget.email;
    state = widget.state;
    AppFunctions.debugPrint(
      'Email data: id=${email.id}, subject=${email.subject}, body=${email.body}, isReplied=${email.isReplied}, replyEmailIds=${email.replyEmailIds}',
    );
    if (!state.read) {
      widget.markMailAsRead?.call();
    }
  }

  Future<int> countUnreadMails() {
    return widget.emailService.countUnreadEmails();
  }

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
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeManage>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final onSurface = theme.colorScheme.onSurface;
    final onSurface60 = onSurface.withOpacity(0.6);
    final onSurface70 = onSurface.withOpacity(0.7);

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.only(left: 16, right: 8),
      child: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('emails')
                .doc(email.id)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            AppFunctions.debugPrint('Error loading email: ${snapshot.error}');
            return const Center(child: Text('Lỗi khi tải email'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final emailData = Email.fromMap(
            snapshot.data!.id,
            snapshot.data!.data()! as Map<String, dynamic>,
          );
          final replyEmailIds = emailData.replyEmailIds;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SubjectRow(
                          email: emailData,
                          state: state,
                          emailService: widget.emailService,
                          onSurface: onSurface,
                          onSurface60: onSurface60,
                          onStarToggled: () {
                            setState(() {
                              state = state.copyWith(starred: !state.starred);
                            });
                          },
                        ),
                        SenderInfo(
                          email: emailData,
                          senderFullName: widget.senderFullName,
                          index: widget.index,
                          onSurface: onSurface,
                          onSurface60: onSurface60,
                          onSurface70: onSurface70,
                          sendReply: widget.sendReply,
                          onShowDetailsToggled: () {
                            setState(() {
                              isShowSendingDetail = !isShowSendingDetail;
                            });
                          },
                          onShowFullBody: () {
                            showDialog<void>(
                              context: context,
                              builder:
                                  (context) => EmailContentDialog(
                                    fullBody: emailData.body,
                                    isDarkMode: isDarkMode,
                                  ),
                            );
                          },
                          isShowSendingDetail: isShowSendingDetail,
                        ),
                        if (isShowSendingDetail)
                          SendingDetailContainer(
                            email: emailData,
                            onSurface70: onSurface70,
                          ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8, bottom: 16),
                          child: Html(
                            data: emailData.body,
                            style: {
                              'body': Style(
                                fontSize: FontSize(16),
                                color: onSurface70,
                              ),
                              'img': Style(
                                display: Display.block,
                                margin: Margins.symmetric(vertical: 8),
                              ),
                              'p': Style(margin: Margins.only(bottom: 8)),
                            },
                          ),
                        ),
                      ],
                    ),
                    if (emailData.isReplied && replyEmailIds.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Divider(
                        thickness: 1,
                        height: 20,
                        indent: 0,
                        endIndent: 0,
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream:
                            replyEmailIds.isNotEmpty
                                ? FirebaseFirestore.instance
                                    .collection('emails')
                                    .where(
                                      FieldPath.documentId,
                                      whereIn: replyEmailIds,
                                    )
                                    .orderBy('timestamp', descending: false)
                                    .snapshots()
                                : null,
                        builder: (context, replySnapshot) {
                          if (replySnapshot.hasError) {
                            AppFunctions.debugPrint(
                              'Error fetching replies: ${replySnapshot.error}',
                            );
                            return const Center(
                              child: Text('Lỗi khi tải reply'),
                            );
                          }
                          if (!replySnapshot.hasData ||
                              replySnapshot.data == null) {
                            AppFunctions.debugPrint(
                              'No reply data for email: ${email.id}',
                            );
                            return const SizedBox.shrink();
                          }

                          final replyDocs = replySnapshot.data!.docs;
                          return Column(
                            children:
                                replyDocs.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final doc = entry.value;
                                  final replyEmail = Email.fromMap(
                                    doc.id,
                                    doc.data()! as Map<String, dynamic>,
                                  );
                                  return Column(
                                    children: [
                                      ReplyItem(
                                        replyEmail: replyEmail,
                                        onSurface60: onSurface60,
                                        onSurface70: onSurface70,
                                        onShowOriginalEmail: () {
                                          showDialog<void>(
                                            context: context,
                                            builder:
                                                (context) => EmailContentDialog(
                                                  fullBody: replyEmail.body,
                                                  isDarkMode: isDarkMode,
                                                ),
                                          );
                                        },
                                      ),
                                      if (index < replyDocs.length - 1)
                                        const Divider(
                                          thickness: 1,
                                          height: 20,
                                          indent: 0,
                                          endIndent: 0,
                                        ),
                                    ],
                                  );
                                }).toList(),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
              UtilsBar(
                email: emailData,
                onSurface60: onSurface60,
                sendReply: widget.sendReply,
                sendReplyAll: widget.sendReplyAll,
                sendForward: widget.sendForward,
              ),
            ],
          );
        },
      ),
    );
  }
}
