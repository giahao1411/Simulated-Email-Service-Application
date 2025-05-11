import 'package:flutter/material.dart';
import '../controllers/email_service.dart';
import './widgets/compose_app_bar.dart';
import './widgets/compose_body.dart';

class ComposeScreen extends StatefulWidget {
  const ComposeScreen({super.key});

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  final TextEditingController toController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  final EmailService emailService = EmailService();

  Future<void> handleSendEmail() async {
    await emailService.sendEmail(
      toController.text,
      subjectController.text,
      bodyController.text,
    );
    Navigator.pop(context);
  }

  Future<void> handleSaveDraft() async {
    await emailService.saveDraft(
      toController.text,
      subjectController.text,
      bodyController.text,
    );
    Navigator.pop(context);
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
        subjectController: subjectController,
        bodyController: bodyController,
      ),
    );
  }
}
