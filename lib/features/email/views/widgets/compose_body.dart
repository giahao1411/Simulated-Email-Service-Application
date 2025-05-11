import 'package:flutter/material.dart';
import './email_text_field.dart';
import '../../../../core/constants/app_strings.dart';

class ComposeBody extends StatelessWidget {
  final TextEditingController toController;
  final TextEditingController subjectController;
  final TextEditingController bodyController;

  const ComposeBody({
    super.key,
    required this.toController,
    required this.subjectController,
    required this.bodyController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          EmailTextField(controller: toController, labelText: AppStrings.to),
          EmailTextField(
            controller: subjectController,
            labelText: AppStrings.subject,
          ),
          Expanded(
            child: EmailTextField(
              controller: bodyController,
              labelText: AppStrings.body,
              maxLines: null,
            ),
          ),
        ],
      ),
    );
  }
}
