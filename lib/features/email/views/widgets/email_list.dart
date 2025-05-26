import 'package:email_application/core/constants/app_strings.dart';
import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/views/screens/mail_detail_screen.dart';
import 'package:email_application/features/email/views/widgets/email_tile.dart';
import 'package:flutter/material.dart';

class EmailList extends StatelessWidget {
  const EmailList({
    required this.emailService,
    required this.currentCategory,
    required this.emailStream,
    this.onRefresh,
    this.refreshStream, // Thêm refreshStream
    super.key,
  });

  final EmailService emailService;
  final String currentCategory;
  final Stream<List<Email>>? emailStream;
  final VoidCallback? onRefresh;
  final VoidCallback? refreshStream; // Thêm tham số

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: StreamBuilder<List<Email>>(
        stream: emailStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                AppStrings.errorLoadingEmails,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                AppStrings.noEmails,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            );
          }

          final emails = snapshot.data!;
          return ListView.builder(
            itemCount: emails.length,
            itemBuilder: (context, index) {
              final email = emails[index];
              return EmailTile(
                email: email,
                index: index,
                emailService: emailService,
                currentCategory: currentCategory,
                onStarToggled: onRefresh,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder:
                          (context) => MailDetail(
                            email: email,
                            onRefresh: onRefresh,
                            refreshStream:
                                refreshStream, // Truyền refreshStream vào MailDetail
                          ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
