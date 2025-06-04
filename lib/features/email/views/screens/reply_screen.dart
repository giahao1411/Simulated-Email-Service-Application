import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/features/email/controllers/draft_service.dart';
import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/draft.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/models/email_state.dart';
import 'package:email_application/features/email/providers/compose_state.dart';
import 'package:email_application/features/email/utils/email_validator.dart';
import 'package:email_application/features/email/views/widgets/compose_app_bar.dart';
import 'package:email_application/features/email/views/widgets/compose_body.dart';
import 'package:email_application/features/email/views/widgets/wysiwyg_text_editor.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
  final EmailService emailService = EmailService();
  final DraftService draftService = DraftService();
  final GlobalKey<WysiwygTextEditorState> _editorKey =
      GlobalKey<WysiwygTextEditorState>();

  @override
  void initState() {
    super.initState();
    toController.text = widget.email.from;
    subjectController.text =
        widget.email.subject.startsWith('Re: ')
            ? widget.email.subject
            : 'Re: ${widget.email.subject}';

    if (widget.draft != null) {
      toController.text = widget.draft!.to.join(', ');
      ccController.text = widget.draft!.cc.join(', ');
      bccController.text = widget.draft!.bcc.join(', ');
      subjectController.text = widget.draft!.subject;
    }
  }

  bool get hasChanges {
    final toEmails = EmailValidator.parseEmails(toController.text);
    final ccEmails = EmailValidator.parseEmails(ccController.text);
    final bccEmails = EmailValidator.parseEmails(bccController.text);
    final subject = subjectController.text.trim();
    final body = _editorKey.currentState?.getFormattedHtml().trim() ?? '';

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

  Future<void> handleSendReply() async {
    final toEmails = EmailValidator.parseEmails(toController.text);
    var body = _editorKey.currentState?.getFormattedHtml().trim() ?? '';
    if (!body.endsWith('\n')) {
      body += '\n';
    }

    if (toEmails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập địa chỉ email người nhận')),
      );
      return;
    }

    try {
      final composeState = Provider.of<ComposeState>(context, listen: false);
      await emailService.sendReply(
        widget.email.id,
        widget.state,
        body,
        attachment:
            composeState.selectedFile != null
                ? {
                  'name': composeState.selectedFile!.name,
                  'bytes': composeState.fileBytes,
                }
                : null,
      );

      if (widget.draft != null) {
        await draftService.deleteDraft(widget.draft!.id);
      }

      composeState.clearSelectedFile();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gửi email trả lời thành công')),
        );
        if (widget.onRefresh != null) {
          widget.onRefresh!();
        }
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

  Future<void> handleSaveDraft() async {
    final toEmails = EmailValidator.parseEmails(toController.text);
    final ccEmails = EmailValidator.parseEmails(ccController.text);
    final bccEmails = EmailValidator.parseEmails(bccController.text);
    final subject = subjectController.text.trim();
    var body = _editorKey.currentState?.getFormattedHtml().trim() ?? '';
    if (!body.endsWith('\n')) {
      body += '\n';
    }

    if (toEmails.isEmpty &&
        ccEmails.isEmpty &&
        bccEmails.isEmpty &&
        subject.isEmpty &&
        body.isEmpty &&
        widget.draft == null) {
      AppFunctions.debugPrint('Empty fields, not saving draft');
      return;
    }

    try {
      final composeState = Provider.of<ComposeState>(context, listen: false);
      await draftService.saveDraft(
        to: toEmails,
        cc: ccEmails,
        bcc: bccEmails,
        subject: subject,
        body: body,
        id: widget.draft?.id,
        attachments:
            composeState.selectedFile != null
                ? [
                  {
                    'name': composeState.selectedFile!.name,
                    'bytes': composeState.fileBytes,
                  },
                ]
                : [],
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
    final initialContent =
        widget.draft == null
            ? '''
Vào ${DateFormat("dd/MM/yyyy 'lúc' HH:mm").format(widget.email.timestamp)}, ${widget.email.from ?? ''} đã viết:
${widget.email.body ?? ''}\n
'''
            : widget.draft!.body;

    return ChangeNotifierProvider(
      create: (_) => ComposeState(),
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final shouldPop = await handleBackAction();
          if (shouldPop && context.mounted) {
            Navigator.pop(context);
          }
        },
        child: Scaffold(
          appBar: ComposeAppBar(
            onSendEmail: handleSendReply,
            onBack: handleBackAction,
            draftId: widget.draft?.id,
            editorKey: _editorKey,
          ),
          body: ComposeBody(
            toController: toController,
            fromController: fromController,
            ccController: ccController,
            bccController: bccController,
            subjectController: subjectController,
            initialContent: initialContent, // Truyền initialContent
            editorKey: _editorKey,
          ),
        ),
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
    super.dispose();
  }
}
