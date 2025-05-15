import 'package:email_application/core/constants/app_strings.dart';
import 'package:email_application/features/email/views/widgets/email_text_field.dart';
import 'package:flutter/material.dart';

class ComposeBody extends StatelessWidget {
  const ComposeBody({
    required this.toController,
    required this.subjectController,
    required this.bodyController,
    super.key,
  });

  final TextEditingController toController;
  final TextEditingController subjectController;
  final TextEditingController bodyController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EmailTextField(
            controller: toController,
            labelText: AppStrings.to,
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 0.5),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
          const SizedBox(height: 4),
          EmailTextField(
            controller: subjectController,
            labelText: AppStrings.subject,
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 0.5),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: EmailTextField(
              controller: bodyController,
              labelText: AppStrings.body,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}
