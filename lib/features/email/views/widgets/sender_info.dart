import 'dart:io';
import 'dart:math';

import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/utils/date_format.dart';
import 'package:email_application/features/email/utils/email_recipients.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SenderInfo extends StatelessWidget {
  const SenderInfo({
    required this.email,
    required this.senderFullName,
    required this.senderPhotoUrl, // Thêm senderPhotoUrl
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
  final String senderPhotoUrl;
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
              recipientText.isEmpty ? '(Không có người nhận)' : recipientText,
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
    return ListTile(
      contentPadding: const EdgeInsets.only(right: -16),
      leading:
          senderPhotoUrl.isNotEmpty
              ? CircleAvatar(
                radius: 20,
                backgroundColor: _getRandomColor(),
                child: ClipOval(
                  child:
                      senderPhotoUrl.startsWith('http')
                          ? Image.network(
                            senderPhotoUrl,
                            fit: BoxFit.cover,
                            width: 40,
                            height: 40,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback nếu lỗi tải ảnh
                              return Text(
                                _getInitial(senderFullName),
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              );
                            },
                          )
                          : Image.file(
                            File(senderPhotoUrl),
                            fit: BoxFit.cover,
                            width: 40,
                            height: 40,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback nếu lỗi tải ảnh
                              return Text(
                                _getInitial(senderFullName),
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                ),
              )
              : CircleAvatar(
                radius: 20,
                backgroundColor: _getRandomColor(),
                child: Text(
                  _getInitial(senderFullName),
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
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
