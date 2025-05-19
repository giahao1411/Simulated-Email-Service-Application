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
  final TextEditingController ccController = TextEditingController();
  final TextEditingController bccController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  final EmailService emailService = EmailService();

  Future<void> handleSendEmail() async {
    if (toController.text.isEmpty) {
      // show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập địa chỉ email người nhận')),
      );
      return;
    }

    // get to, cc, and bcc emails
    final toEmails = toController.text.split(',').map((e) => e.trim()).toList();
    final ccEmails =
        ccController.text.isNotEmpty
            ? ccController.text.split(',').map((e) => e.trim()).toList()
            : <String>[];
    final bccEmails =
        bccController.text.isNotEmpty
            ? bccController.text.split(',').map((e) => e.trim()).toList()
            : <String>[];

    // send mail
    try {
      await emailService.sendEmail(
        to: toEmails,
        cc: ccEmails,
        bcc: bccEmails,
        subject: subjectController.text,
        body: bodyController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gửi email thành công')));
        Navigator.pop(context);
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gửi email thất bại: $e')));
      }
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
        ccController: ccController,
        bccController: bccController,
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
