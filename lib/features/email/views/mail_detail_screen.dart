import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/utils/date_format.dart';
import 'package:flutter/material.dart';

class EmailDetail extends StatefulWidget {
  const EmailDetail({required this.email, super.key});

  final Email email;

  @override
  State<EmailDetail> createState() => _EmailDetailState();
}

class _EmailDetailState extends State<EmailDetail> {
  late Email email;

  @override
  void initState() {
    super.initState();
    email = widget.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết email'),
        backgroundColor: Colors.grey[900],
      ),
      body: Container(
        color: Colors.grey[900],
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'From: ${email.from}',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'To: ${email.to.join(', ')}',
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 8),
            if (email.cc.isNotEmpty)
              Text(
                'CC: ${email.cc.join(', ')}',
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
            const SizedBox(height: 8),
            if (email.bcc.isNotEmpty)
              Text(
                'BCC: ${email.bcc.join(', ')}',
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
            const SizedBox(height: 16),
            Text(
              'Subject: ${email.subject}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(email.body, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            Text(
              'Date: ${DateFormat.formatTimestamp(email.timestamp)}',
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
