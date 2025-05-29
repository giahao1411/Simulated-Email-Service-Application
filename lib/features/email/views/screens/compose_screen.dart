import 'package:email_application/core/constants/app_functions.dart';
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

  // check if any of the text fields have data
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
      return true; // Cho phép thoát
    }

    final shouldSave = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Lưu thư nháp?'),
            content: const Text('Bạn có muốn lưu thư nháp trước khi thoát?'),
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

  Future<void> handleSendEmail() async {
    // get to, cc, and bcc emails
    final toEmails = EmailValidator.parseEmails(toController.text);
    final ccEmails = EmailValidator.parseEmails(ccController.text);
    final bccEmails = EmailValidator.parseEmails(bccController.text);

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

  Future<void> handleSaveDraft({bool showSnackBar = true}) async {
    // get to, cc, and bcc emails
    final toEmails = EmailValidator.parseEmails(toController.text);
    final ccEmails = EmailValidator.parseEmails(ccController.text);
    final bccEmails = EmailValidator.parseEmails(bccController.text);
    final subject = subjectController.text.trim();
    final body = bodyController.text.trim();

    // Bỏ qua nếu không có dữ liệu
    if (toEmails.isEmpty &&
        ccEmails.isEmpty &&
        bccEmails.isEmpty &&
        subject.isEmpty &&
        body.isEmpty &&
        widget.draft == null) {
      AppFunctions.debugPrint('Các trường rỗng, không lưu nháp');
      return;
    }

    // Kiểm tra thay đổi
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
        body: bodyController.text,
        id: widget.draft?.id, // update draft if it exists
      );
      if (mounted && showSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lưu thư nháp thành công')),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lưu thư nháp thất bại: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // disable default back button behavior
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // if pop was invoked, do nothing
        if (await handleBackAction()) {
          Navigator.pop(context); // pop the screen if back action is allowed
        }
      },
      child: Scaffold(
        appBar: ComposeAppBar(
          onSendEmail: handleSendEmail,
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
