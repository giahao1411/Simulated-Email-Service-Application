import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/models/email_state.dart';
import 'package:flutter/material.dart';

class SubjectRow extends StatelessWidget {
  const SubjectRow({
    required this.email,
    required this.state,
    required this.emailService,
    required this.onSurface,
    required this.onSurface60,
    required this.onStarToggled,
    super.key,
  });

  final Email email;
  final EmailState state;
  final EmailService emailService;
  final Color onSurface;
  final Color onSurface60;
  final VoidCallback onStarToggled;

  @override
  Widget build(BuildContext context) {
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
            await emailService.toggleStar(email.id, state.starred);
            onStarToggled();
          },
        ),
      ],
    );
  }
}
