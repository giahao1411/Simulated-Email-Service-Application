import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/models/email_state.dart';
import 'package:email_application/features/email/views/widgets/compose_app_bar.dart';
import 'package:email_application/features/email/views/widgets/compose_body.dart';
import 'package:flutter/material.dart';

class ReplyScreen extends StatefulWidget {
  const ReplyScreen({
    required this.email,
    required this.state,
    this.onRefresh,
    super.key,
  });

  final Email email;
  final EmailState state;
  final VoidCallback? onRefresh;

  @override
  State<ReplyScreen> createState() => _ReplyScreenState();
}

class _ReplyScreenState extends State<ReplyScreen> {
  final TextEditingController toController = TextEditingController();
  final TextEditingController fromController = TextEditingController();
  final TextEditingController ccController = TextEditingController();
  final TextEditingController bccController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  final EmailService emailService = EmailService();

  @override
  void initState() {
    super.initState();
    // Điền thông tin mặc định cho reply
    toController.text = widget.email.from; // Người nhận là người gửi email gốc
    subjectController.text =
        widget.email.subject.startsWith('Re: ')
            ? widget.email.subject
            : 'Re: ${widget.email.subject}';
  }

  Future<void> handleSendReply() async {
    // Validate dữ liệu
    if (toController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập địa chỉ email người nhận')),
      );
      return;
    }

    try {
      await emailService.sendReply(
        widget.email.id,
        widget.state,
        bodyController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gửi email trả lời thành công')),
        );
        widget.onRefresh?.call();
        Navigator.pop(context);
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gửi email trả lời thất bại: $e')),
        );
      }
    }
  }

  Future<void> handleSaveDraft() async {
    // Lưu nội dung reply dưới dạng nháp (tùy chọn)
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

    await emailService.saveDraft(
      to: toEmails,
      cc: ccEmails,
      bcc: bccEmails,
      subject: subjectController.text,
      body: bodyController.text,
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
        onSendEmail: handleSendReply,
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
    fromController.dispose();
    ccController.dispose();
    bccController.dispose();
    subjectController.dispose();
    bodyController.dispose();
    super.dispose();
  }
}
