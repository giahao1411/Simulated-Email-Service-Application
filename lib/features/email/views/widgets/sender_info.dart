import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/utils/date_format.dart';
import 'package:email_application/features/email/utils/email_recipients.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SenderInfo extends StatelessWidget {
  const SenderInfo({
    required this.email,
    required this.senderFullName,
    required this.index,
    required this.onSurface,
    required this.onSurface60,
    required this.onSurface70,
    required this.sendReply,
    required this.onShowDetailsToggled,
    required this.onShowFullBody,
    required this.isShowSendingDetail,
    super.key,
  });

  final Email email;
  final String senderFullName;
  final int index;
  final Color onSurface;
  final Color onSurface60;
  final Color onSurface70;
  final VoidCallback sendReply;
  final VoidCallback onShowDetailsToggled;
  final VoidCallback onShowFullBody;
  final bool isShowSendingDetail;

  Widget buildSendingDetail(Email email, Color onSurface70) {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    final recipientText = EmailRecipient.formatRecipient(
      email.to,
      email.bcc,
      currentUserEmail,
    );

    return GestureDetector(
      onTap: onShowDetailsToggled,
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

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(right: -16),
      leading: CircleAvatar(
        backgroundImage: NetworkImage('https://picsum.photos/250?image=$index'),
      ),
      title: Row(
        children: [
          Text(
            senderFullName.isEmpty ? email.from : senderFullName,
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
            onPressed: email.from.isEmpty ? null : sendReply,
          ),
          IconButton(
            icon: Icon(Icons.more_horiz, color: onSurface60),
            onPressed: onShowFullBody,
          ),
        ],
      ),
      onTap: () {},
    );
  }
}
