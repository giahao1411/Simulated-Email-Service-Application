import 'package:email_application/core/constants/app_strings.dart';
import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/models/email_state.dart';
import 'package:email_application/features/email/views/screens/mail_detail_screen.dart';
import 'package:email_application/features/email/views/widgets/email_tile.dart';
import 'package:flutter/material.dart';

class EmailList extends StatelessWidget {
  const EmailList({
    required this.emailService,
    required this.currentCategory,
    required this.emailStream,
    required this.onRefresh,
    super.key,
  });

  final EmailService emailService;
  final String currentCategory;
  final Stream<List<Map<String, dynamic>>> emailStream;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh!(),
      child: ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: StreamBuilder<List<Map<String, dynamic>>>(
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

            final emailsWithState = snapshot.data!;
            return ListView.builder(
              itemCount: emailsWithState.length,
              itemBuilder: (context, index) {
                final email = emailsWithState[index]['email'] as Email;
                final state = emailsWithState[index]['state'] as EmailState;
                final senderFullName =
                    emailsWithState[index]['senderFullName']
                        as String; // Lấy senderFullName
                return EmailTile(
                  email: email,
                  state: state,
                  index: index,
                  emailService: emailService,
                  currentCategory: currentCategory,
                  senderFullName:
                      senderFullName, // Truyền senderFullName vào EmailTile
                  onStarToggled: onRefresh,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder:
                            (context) => MailDetail(
                              email: email,
                              state: state,
                              senderFullName:
                                  senderFullName, // Truyền senderFullName vào MailDetail
                              onRefresh: onRefresh,
                            ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
