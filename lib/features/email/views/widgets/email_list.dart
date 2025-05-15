import 'package:email_application/core/constants/app_strings.dart';
import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/views/widgets/email_tile.dart';
import 'package:flutter/material.dart';

class EmailList extends StatelessWidget {

  const EmailList({
    required this.emailService, required this.currentCategory, super.key,
  });
  final EmailService emailService;
  final String currentCategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      child: StreamBuilder<List<Email>>(
        stream: emailService.getEmails(currentCategory),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                AppStrings.noEmails,
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          final emails = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: emails.length,
            itemBuilder: (context, index) {
              final email = emails[index];
              return EmailTile(email: email, index: index);
            },
          );
        },
      ),
    );
  }
}
