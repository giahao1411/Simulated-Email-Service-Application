import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/core/constants/app_strings.dart';
import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/models/email_state.dart';
import 'package:email_application/features/email/utils/date_format.dart';
import 'package:email_application/features/email/utils/email_recipients.dart';
import 'package:email_application/features/email/views/screens/mail_detail_screen.dart';
import 'package:email_application/features/email/views/widgets/reply_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MailDetailBody extends StatefulWidget {
  MailDetailBody({
    required this.email,
    required this.state,
    required this.index,
    required this.senderFullName,
    required this.sendReply,
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
    if (body.isEmpty) return '(No content)';
    final quoteIndex = body.indexOf('On ');
    return quoteIndex != -1
        ? body.substring(0, quoteIndex).trim()
        : body.trim();
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
                        _buildSubjectRow(onSurface, onSurface60),
                        _buildSenderInfo(
                          onSurface,
                          onSurface70,
                          onSurface60,
                          context,
                        ),
                        if (isShowSendingDetail)
                          _buildSendingDetailContainer(emailData, onSurface70),
                        Padding(
                          padding: const EdgeInsets.only(right: 8, bottom: 16),
                          child: Text(
                            getSummaryBody(emailData.body),
                            style: TextStyle(fontSize: 16, color: onSurface70),
                          ),
                        ),
                      ],
                    ),
                    if (replyEmailIds.isNotEmpty) ...[
                      const Divider(
                        thickness: 1,
                        height: 20,
                        indent: 16,
                        endIndent: 8,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 16, right: 8, bottom: 8),
                      ),
                    ],
                    if (replyEmailIds.isNotEmpty)
                      StreamBuilder<QuerySnapshot>(
                        stream:
                            replyEmailIds.isNotEmpty
                                ? FirebaseFirestore.instance
                                    .collection('emails')
                                    .where(
                                      FieldPath.documentId,
                                      whereIn: replyEmailIds,
                                    )
                                    .orderBy('timestamp', descending: true)
                                    .snapshots()
                                : null,
                        builder: (context, replySnapshot) {
                          if (replySnapshot.hasError) {
                            AppFunctions.debugPrint(
                              'Error loading replies: ${replySnapshot.error}',
                            );
                            return const Center(
                              child: Text('Lỗi khi tải phản hồi'),
                            );
                          }
                          if (!replySnapshot.hasData ||
                              replySnapshot.data!.docs.isEmpty) {
                            AppFunctions.debugPrint(
                              'No replies found for email ${emailData.id}',
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
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute<void>(
                                              builder:
                                                  (context) => MailDetail(
                                                    email: emailData,
                                                    state: state,
                                                    senderFullName:
                                                        widget.senderFullName,
                                                    onRefresh: widget.onRefresh,
                                                  ),
                                            ),
                                          );
                                        },
                                        child: ReplyItem(
                                          replyEmail: replyEmail,
                                          onSurface60: onSurface60,
                                          onShowOriginalEmail:
                                              () => _showFullBodyDialog(
                                                context,
                                                replyEmail.body,
                                              ),
                                        ),
                                      ),
                                      if (index < replyDocs.length - 1)
                                        const Divider(
                                          thickness: 1,
                                          height: 20,
                                          indent: 16,
                                          endIndent: 8,
                                        ),
                                    ],
                                  );
                                }).toList(),
                          );
                        },
                      ),
                  ],
                ),
              ),
              _buildUtilsBar(onSurface60),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSubjectRow(Color onSurface, Color onSurface60) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            email.subject.isEmpty ? '(No subject)' : email.subject,
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
            await widget.emailService.toggleStar(email.id, state.starred);
            setState(() {
              state = state.copyWith(starred: !state.starred);
            });
          },
        ),
      ],
    );
  }

  Widget _buildSenderInfo(
    Color onSurface,
    Color onSurface70,
    Color onSurface60,
    BuildContext context,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.only(right: -16),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(
          'https://picsum.photos/250?image=${widget.index}',
        ),
      ),
      title: Row(
        children: [
          Text(
            widget.senderFullName.isEmpty ? email.from : widget.senderFullName,
            style: TextStyle(color: onSurface),
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
            onPressed: widget.email.from.isEmpty ? null : widget.sendReply,
          ),
          IconButton(
            icon: Icon(Icons.more_horiz, color: onSurface60),
            onPressed: () {
              _showFullBodyDialog(context, email.body);
            },
          ),
        ],
      ),
      onTap: () {},
    );
  }

  Widget _buildUtilsBar(Color onSurface60) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          OverflowBar(
            alignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: widget.email.from.isEmpty ? null : widget.sendReply,
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
                  onPressed: null, // Chưa triển khai Reply All
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
                      Text('Reply all', style: TextStyle(color: onSurface60)),
                    ],
                  ),
                ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: null, // Chưa triển khai Forward
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
              recipientText.isEmpty ? '(No recipients)' : recipientText,
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

  Widget _buildSendingDetailContainer(Email email, Color onSurface70) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(top: 4, bottom: 20, right: 8),
      decoration: BoxDecoration(
        border: Border.all(color: onSurface70.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: buildSendingDetailContainer(email, onSurface70),
    );
  }

  void _showFullBodyDialog(BuildContext context, String fullBody) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Chi tiết nội dung'),
            content: SingleChildScrollView(
              child: Text(fullBody.isEmpty ? '(No content)' : fullBody),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
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
                email.from.isEmpty ? '(No sender)' : email.from,
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
                      spacing: 8,
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
                      spacing: 8,
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
                      spacing: 8,
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
