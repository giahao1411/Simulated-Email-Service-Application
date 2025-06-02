import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/features/email/controllers/draft_service.dart';
import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/draft.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/models/email_state.dart';
import 'package:email_application/features/email/utils/date_format.dart';
import 'package:email_application/features/email/utils/email_validator.dart';
import 'package:email_application/features/email/views/widgets/compose_app_bar.dart';
import 'package:email_application/features/email/views/widgets/compose_body.dart';
import 'package:flutter/material.dart';

class ForwardScreen extends StatefulWidget {
  const ForwardScreen({
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
  State<ForwardScreen> createState() => _ForwardScreenState();
}

class _ForwardScreenState extends State<ForwardScreen> {
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
    subjectController.text =
        widget.email.subject.startsWith('Fwd: ')
            ? widget.email.subject
            : 'Fwd: ${widget.email.subject}';

    bodyController.text = '''
---------- Tin nhắn chuyển tiếp ---------
Từ: ${widget.email.from}
Ngày: ${DateFormat.formatDetailedTimestamp(widget.email.timestamp)}
Tiêu đề: ${widget.email.subject}
Đến: ${widget.email.to.join(', ')}
${widget.email.cc.isNotEmpty ? 'Cc: ${widget.email.cc.join(', ')}\n' : ''}
${widget.email.bcc.isNotEmpty ? 'Bcc: ${widget.email.bcc.join(', ')}\n' : ''}

${widget.email.body}
''';
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

    await handleSaveDraft();

    return true;
  }

  Future<void> handleSendForward() async {
    final toEmails = EmailValidator.parseEmails(toController.text);
    final ccEmails = EmailValidator.parseEmails(ccController.text);
    final bccEmails = EmailValidator.parseEmails(bccController.text);

    if (toEmails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập địa chỉ email người nhận')),
      );
      return;
    }

    try {
      await emailService.sendForward(
        widget.email.id,
        bodyController.text,
        toEmails,
        ccEmails: ccEmails,
        bccEmails: bccEmails,
        onRefresh: widget.onRefresh,
      );

      if (widget.draft != null) {
        await draftService.deleteDraft(widget.draft!.id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gửi email chuyển tiếp thành công')),
        );
        if (widget.onRefresh != null) {
          widget.onRefresh!.call();
        }
        Navigator.pop(context);
      }
    } on Exception catch (e) {
      if (mounted) {
        AppFunctions.debugPrint('Error sending forward: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gửi email chuyển tiếp thất bại: $e')),
        );
      }
    }
  }

  Future<void> handleSaveDraft() async {
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lưu thư nháp thành công')),
        );
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
        onSendEmail: handleSendForward,
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
