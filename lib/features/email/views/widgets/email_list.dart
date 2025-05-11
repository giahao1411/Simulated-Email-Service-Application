import 'package:flutter/material.dart';
import '../../controllers/email_service.dart';
import '../../models/email.dart';
import './email_tile.dart';
import '../../../../core/constants/app_strings.dart';

class EmailList extends StatelessWidget {
  final EmailService emailService;
  final String currentCategory;

  const EmailList({
    super.key,
    required this.emailService,
    required this.currentCategory,
  });

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
          var emails = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: emails.length,
            itemBuilder: (context, index) {
              var email = emails[index];
              return EmailTile(email: email, index: index);
            },
          );
        },
      ),
    );
  }
}
