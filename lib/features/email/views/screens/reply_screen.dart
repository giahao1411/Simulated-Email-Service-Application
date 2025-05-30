import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/features/email/controllers/draft_service.dart';
import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/draft.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/models/email_state.dart';
import 'package:email_application/features/email/utils/email_validator.dart';
import 'package:email_application/features/email/views/widgets/compose_app_bar.dart';
import 'package:email_application/features/email/views/widgets/compose_body.dart';
import 'package:flutter/material.dart';

class ReplyScreen extends StatefulWidget {
  const ReplyScreen({
    required this.email,
    required this.state,
    this.draft,
    this.onRefresh,
    super.key,
  });

  final Email email;
  final Draft? draft;
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
  final DraftService draftService = DraftService();

  @override
  void initState() {
    super.initState();
    toController.text = widget.email.from; // Người nhận là người gửi email gốc
    subjectController.text =
        widget.email.subject.startsWith('Re: ')
            ? widget.email.subject
            : 'Re: ${widget.email.subject}';
    if (widget.draft != null) {
      toController.text = widget.draft!.to.join(', ');
      ccController.text = widget.draft!.cc.join(', ');
      bccController.text = widget.draft!.bcc.join(', ');
      subjectController.text = widget.draft!.subject;
      bodyController.text = widget.draft!.body;
    }
  }

  bool get hasChanges {
    final toEmails = EmailValidator.parseEmails(toController.text);
    final ccEmails = EmailValidator.parseEmails(ccController.text);
    final bccEmails = EmailValidator.parseEmails(bccController.text);
    final subject = subjectController.text.trim();
    final body = bodyController.text.trim();

    if (widget.draft == null) {
      return toEmails.isNotEmpty ||
          ccEmails.isNotEmpty ||
          bccEmails.isNotEmpty ||
          subject.isNotEmpty ||
          body.isNotEmpty;
    }

    return widget.draft!.to.join(',') != toEmails.join(',') ||
        widget.draft!.cc.join(',') != ccEmails.join(',') ||
        widget.draft!.bcc.join(',') != bccEmails.join(',') ||
        widget.draft!.subject != subject ||
        widget.draft!.body != body;
  }

  Future<bool> handleBackAction() async {
    if (!hasChanges) {
      AppFunctions.debugPrint('Không có thay đổi, bỏ qua lưu nháp');
      return true;
    }

    final shouldSave = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Lưu thư nháp?'),
            content: const Text(
              'Bạn có muốn lưu nội dung trả lời này vào thư nháp trước khi thoát không?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Lưu'),
              ),
            ],
          ),
    );

    if (shouldSave ?? false) {
      await handleSaveDraft(showSnackBar: false);
    }
    return true;
  }

  Future<void> handleSendReply() async {
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

      if (widget.draft != null) {
        await draftService.deleteDraft(widget.draft!.id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gửi email trả lời thành công')),
        );
        widget.onRefresh?.call();
        Navigator.pop(context);
      }
    } on Exception catch (e) {
      if (mounted) {
        AppFunctions.debugPrint('Error sending reply: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gửi email trả lời thất bại: $e')),
        );
      }
    }
  }

  Future<void> handleSaveDraft({bool showSnackBar = true}) async {
    final toEmails = EmailValidator.parseEmails(toController.text);
    final ccEmails = EmailValidator.parseEmails(ccController.text);
    final bccEmails = EmailValidator.parseEmails(bccController.text);
    final subject = subjectController.text.trim();
    final body = bodyController.text.trim();
    if (toEmails.isEmpty &&
        ccEmails.isEmpty &&
        bccEmails.isEmpty &&
        subject.isEmpty &&
        body.isEmpty &&
        widget.draft == null) {
      AppFunctions.debugPrint('Empty fields, not saving draft');
      return;
    }

    if (!hasChanges && widget.draft != null) {
      AppFunctions.debugPrint(
        'Không có thay đổi, bỏ qua lưu nháp: ${widget.draft!.id}',
      );
      return;
    }

    try {
      await draftService.saveDraft(
        to: toEmails,
        cc: ccEmails,
        bcc: bccEmails,
        subject: subjectController.text,
        body: body,
        id: widget.draft?.id,
      );

      if (mounted && showSnackBar) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Lưu nháp thành công')));
      }
    } on Exception catch (e) {
      if (mounted) {
        AppFunctions.debugPrint('Error saving draft: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lưu nháp thất bại: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ComposeAppBar(
        onSendEmail: handleSendReply,
        onBack: handleBackAction,
        draftId: widget.draft?.id,
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
