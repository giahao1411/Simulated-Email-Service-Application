import 'package:email_application/core/constants/app_strings.dart';
import 'package:email_application/features/email/views/widgets/email_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ComposeBody extends StatelessWidget {
  const ComposeBody({
    required this.toController,
    required this.fromController,
    required this.subjectController,
    required this.bodyController,
    super.key,
  });

  final TextEditingController toController;
  final TextEditingController fromController;
  final TextEditingController subjectController;
  final TextEditingController bodyController;

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    fromController.text = userEmail ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 16, left: 16),
              child: Text(
                AppStrings.to,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: EmailTextField(
                  controller: toController,
                  labelText: '',
                  useLabelAsFixed: true,
                  suffixIcon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ],
        ),
        Divider(color: Colors.grey[300], height: 1, thickness: 0.75),
        Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 16, left: 16),
              child: Text(
                AppStrings.from,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: EmailTextField(
                  controller: fromController,
                  labelText: '',
                  useLabelAsFixed: true,
                  suffixIcon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ],
        ),
        Divider(color: Colors.grey[300], height: 1, thickness: 0.75),
        EmailTextField(
          controller: subjectController,
          labelText: AppStrings.subject,
        ),
        Divider(color: Colors.grey[300], height: 1, thickness: 0.75),
        Expanded(
          child: EmailTextField(
            controller: bodyController,
            labelText: AppStrings.composeEmail,
            keyboardType: TextInputType.multiline,
          ),
        ),
      ],
    );
  }
}
