import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/utils/date_format.dart';
import 'package:flutter/material.dart';

class MailDetailBody extends StatelessWidget {
  const MailDetailBody({required this.email, super.key});

  final Email email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          emailHeader(
            from: email.from,
            to: email.to,
            cc: email.cc,
            bcc: email.bcc,
            theme: theme,
          ),
          const SizedBox(height: 16),
          // Subject section
          Text(
            'Subject: ${email.subject}',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Body section
          Text(
            email.body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Date: ${DateFormat.formatTimestamp(email.timestamp)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
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
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'From: $from',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'To: ${to.join(', ')}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        if (cc.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'CC: ${cc.join(', ')}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
        if (bcc.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'BCC: ${bcc.join(', ')}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ],
    );
  }
}
