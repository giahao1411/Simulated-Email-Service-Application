import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/views/widgets/compose_app_bar.dart';
import 'package:email_application/features/email/views/widgets/compose_body.dart';
import 'package:flutter/material.dart';

class ComposeScreen extends StatefulWidget {
  const ComposeScreen({super.key});

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  final TextEditingController toController = TextEditingController();
  final TextEditingController fromController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  final EmailService emailService = EmailService();

  Future<void> handleSendEmail() async {
    await emailService.sendEmail(
      toController.text,
      subjectController.text,
      bodyController.text,
    );
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> handleSaveDraft() async {
    await emailService.saveDraft(
      toController.text,
      subjectController.text,
      bodyController.text,
    );
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComposeAppBar(
        onSaveDraft: handleSaveDraft,
        onSendEmail: handleSendEmail,
      ),
      body: ComposeBody(
        toController: toController,
        fromController: fromController,
        subjectController: subjectController,
        bodyController: bodyController,
      ),
    );
  }

  @override
  void dispose() {
    toController.dispose();
    subjectController.dispose();
    bodyController.dispose();
    super.dispose();
  }
}
