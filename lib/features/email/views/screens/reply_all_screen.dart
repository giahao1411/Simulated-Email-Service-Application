import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/features/email/controllers/draft_service.dart';
import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/draft.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/models/email_state.dart';
import 'package:email_application/features/email/providers/compose_state.dart';
import 'package:email_application/features/email/utils/date_format.dart';
import 'package:email_application/features/email/utils/email_validator.dart';
import 'package:email_application/features/email/views/widgets/compose_app_bar.dart';
import 'package:email_application/features/email/views/widgets/compose_body.dart';
import 'package:email_application/features/email/views/widgets/wysiwyg_text_editor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReplyAllScreen extends StatefulWidget {
  const ReplyAllScreen({
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
  State<ReplyAllScreen> createState() => _ReplyAllScreenState();
}

class _ReplyAllScreenState extends State<ReplyAllScreen> {
  final TextEditingController toCtrl = TextEditingController();
  final TextEditingController fromCtrl = TextEditingController();
  final TextEditingController ccCtrl = TextEditingController();
  final TextEditingController bccCtrl = TextEditingController();
  final TextEditingController subjectCtrl = TextEditingController();
  final EmailService emailService = EmailService();
  final DraftService draftService = DraftService();
  final GlobalKey<WysiwygTextEditorState> _editorKey =
      GlobalKey<WysiwygTextEditorState>();

  @override
  void initState() {
    super.initState();
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    final isCc = widget.email.cc.contains(currentUserEmail);
    final isBcc = widget.email.bcc.contains(currentUserEmail);

    if (isCc) {
      final ccEmails =
          <String>{
            widget.email.from,
            ...widget.email.to,
            ...widget.email.cc,
          }.where((email) => email != currentUserEmail).toList();
      ccCtrl.text = ccEmails.join(', ');
      toCtrl.text = widget.email.from;
      bccCtrl.text = '';
    } else if (isBcc) {
      bccCtrl.text = widget.email.from;
      toCtrl.text = '';
      ccCtrl.text = '';
    } else {
      final toEmails =
          <String>{
            widget.email.from,
            ...widget.email.to,
          }.where((email) => email != currentUserEmail).toList();
      toCtrl.text = toEmails.join(', ');
      final ccEmails =
          widget.email.cc.where((email) => email != currentUserEmail).toList();
      ccCtrl.text = ccEmails.join(', ');
      bccCtrl.text = '';
    }

    subjectCtrl.text =
        widget.email.subject.startsWith('Re: ')
            ? widget.email.subject
            : 'Re: ${widget.email.subject}';

    if (widget.draft != null) {
      toCtrl.text = widget.draft!.to.join(', ');
      ccCtrl.text = widget.draft!.cc.join(', ');
      bccCtrl.text = widget.draft!.bcc.join(', ');
      subjectCtrl.text = widget.draft!.subject;
    }
  }

  bool get hasChanges {
    final toEmails = EmailValidator.parseEmails(toCtrl.text);
    final ccEmails = EmailValidator.parseEmails(ccCtrl.text);
    final bccEmails = EmailValidator.parseEmails(bccCtrl.text);
    final subject = subjectCtrl.text.trim();
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

  Future<void> handleSendReplyAll() async {
    final toEmails = EmailValidator.parseEmails(toCtrl.text);
    final ccEmails = EmailValidator.parseEmails(ccCtrl.text);
    final bccEmails = EmailValidator.parseEmails(bccCtrl.text);
    var body = _editorKey.currentState?.getFormattedHtml().trim() ?? '';
    if (!body.endsWith('\n')) {
      body += '\n';
    }

    if (toEmails.isEmpty && ccEmails.isEmpty && bccEmails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập ít nhất một người nhận')),
      );
      return;
    }

    try {
      final composeState = Provider.of<ComposeState>(context, listen: false);
      await emailService.sendReply(
        widget.email.id,
        widget.state,
        body,
        ccEmails: ccEmails,
        bccEmails: bccEmails,
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
          const SnackBar(content: Text('Gửi email trả lời tất cả thành công')),
        );
        if (widget.onRefresh != null) {
          widget.onRefresh!.call();
        }
        Navigator.pop(context);
      }
    } on Exception catch (e) {
      if (mounted) {
        AppFunctions.debugPrint('Error sending reply all: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gửi email trả lời tất cả thất bại: $e')),
        );
      }
    }
  }

  Future<void> handleSaveDraft() async {
    final toEmails = EmailValidator.parseEmails(toCtrl.text);
    final ccEmails = EmailValidator.parseEmails(ccCtrl.text);
    final bccEmails = EmailValidator.parseEmails(bccCtrl.text);
    final subject = subjectCtrl.text.trim();
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
Vào ${DateFormat.formatDetailedTimestamp(widget.email.timestamp)}, ${widget.email.from} đã viết:
${widget.email.body}\n
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
            onSendEmail: handleSendReplyAll,
            onBack: handleBackAction,
            draftId: widget.draft?.id,
            editorKey: _editorKey,
          ),
          body: ComposeBody(
            toController: toCtrl,
            fromController: fromCtrl,
            ccController: ccCtrl,
            bccController: bccCtrl,
            subjectController: subjectCtrl,
            initialContent: initialContent,
            editorKey: _editorKey,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    toCtrl.dispose();
    fromCtrl.dispose();
    ccCtrl.dispose();
    bccCtrl.dispose();
    subjectCtrl.dispose();
    super.dispose();
  }
}
