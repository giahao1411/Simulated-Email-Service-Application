import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/utils/date_format.dart';
import 'package:flutter/material.dart';

class MailDetailBody extends StatelessWidget {
  const MailDetailBody({required this.email, super.key});

  final Email email;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          emailHeader(
            from: email.from,
            to: email.to,
            cc: email.cc,
            bcc: email.bcc,
          ),
          const SizedBox(height: 16),
          // Subject section
          Text(
            'Subject: ${email.subject}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Body section
          Text(email.body, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          Text(
            'Date: ${DateFormat.formatTimestamp(email.timestamp)}',
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget emailHeader({
    required String from,
    required List<String> to,
    required List<String> cc,
    required List<String> bcc,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'From: $from',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          'To: ${to.join(', ')}',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
        if (cc.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'CC: ${cc.join(', ')}',
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
        if (bcc.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'BCC: ${bcc.join(', ')}',
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ],
    );
  }
}
