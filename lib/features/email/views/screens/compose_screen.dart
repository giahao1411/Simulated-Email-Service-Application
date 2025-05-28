import 'package:email_application/features/email/controllers/draft_service.dart';
import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/draft.dart';
import 'package:email_application/features/email/utils/email_validator.dart';
import 'package:email_application/features/email/views/widgets/compose_app_bar.dart';
import 'package:email_application/features/email/views/widgets/compose_body.dart';
import 'package:flutter/material.dart';

class ComposeScreen extends StatefulWidget {
  const ComposeScreen({this.draft, super.key});

  final Draft? draft;

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
  final DraftService draftService = DraftService();

  @override
  void initState() {
    super.initState();
    // fill controllers with draft data if available
    if (widget.draft != null) {
      toController.text = widget.draft!.to.join(', ');
      ccController.text = widget.draft!.cc.join(', ');
      bccController.text = widget.draft!.bcc.join(', ');
      subjectController.text = widget.draft!.subject;
      bodyController.text = widget.draft!.body;
    }
  }

  Future<void> handleSendEmail() async {
    // get to, cc, and bcc emails
    final toEmails =
        toController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
    final ccEmails =
        ccController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
    final bccEmails =
        bccController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    // validate data
    if (toEmails.isEmpty && ccEmails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập địa chỉ email người nhận')),
      );
      return;
    }
    if (!EmailValidator.validateEmails(toController.text) ||
        !EmailValidator.validateEmails(ccController.text) ||
        !EmailValidator.validateEmails(bccController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Địa chỉ email người nhận không hợp lệ')),
      );
      return;
    }

    // send mail
    try {
      await emailService.sendEmail(
        to: toEmails,
        cc: ccEmails,
        bcc: bccEmails,
        subject: subjectController.text,
        body: bodyController.text,
      );

      if (widget.draft != null) {
        // if this is a draft, delete it after sending
        await draftService.deleteDraft(widget.draft!.id);
      }

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
    // get to, cc, and bcc emails
    final toEmails =
        toController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
    final ccEmails =
        ccController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
    final bccEmails =
        bccController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

    await draftService.saveDraft(
      to: toEmails,
      cc: ccEmails,
      bcc: bccEmails,
      subject: subjectController.text,
      body: bodyController.text,
      id: widget.draft?.id, // update draft if it exists
    );
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lưu thư nháp thành công')));
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
