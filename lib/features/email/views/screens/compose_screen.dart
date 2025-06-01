import 'dart:convert';

import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/features/email/controllers/draft_service.dart';
import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/draft.dart';
import 'package:email_application/features/email/providers/compose_state.dart';
import 'package:email_application/features/email/utils/email_validator.dart';
import 'package:email_application/features/email/views/widgets/compose_app_bar.dart';
import 'package:email_application/features/email/views/widgets/compose_body.dart';
import 'package:email_application/features/email/views/widgets/wysiwyg_text_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  final GlobalKey<WysiwygTextEditorState> _editorKey =
      GlobalKey<WysiwygTextEditorState>();

  @override
  void initState() {
    super.initState();
    if (widget.draft != null) {
      toController.text = widget.draft!.to.join(', ');
      ccController.text = widget.draft!.cc.join(', ');
      bccController.text = widget.draft!.bcc.join(', ');
      subjectController.text = widget.draft!.subject;
      bodyController.text = widget.draft!.body;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_editorKey.currentState != null && widget.draft!.body.isNotEmpty) {
          _editorKey.currentState!.setHtml(widget.draft!.body);
          AppFunctions.debugPrint(
            'Loaded draft body into editor: ${widget.draft!.body}',
          );
        }
      });
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

  Future<void> handleSendEmail() async {
    final toEmails = EmailValidator.parseEmails(toController.text);
    final ccEmails = EmailValidator.parseEmails(ccController.text);
    final bccEmails = EmailValidator.parseEmails(bccController.text);
    final body = _editorKey.currentState?.getFormattedHtml().trim() ?? '';

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

    try {
      final composeState = Provider.of<ComposeState>(context, listen: false);
      await emailService.sendEmail(
        to: toEmails,
        cc: ccEmails,
        bcc: bccEmails,
        subject: subjectController.text,
        body: body,
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
    final toEmails = EmailValidator.parseEmails(toController.text);
    final ccEmails = EmailValidator.parseEmails(ccController.text);
    final bccEmails = EmailValidator.parseEmails(bccController.text);
    final subject = subjectController.text.trim();
    final body = _editorKey.currentState?.getFormattedHtml().trim() ?? '';

    if (toEmails.isEmpty &&
        ccEmails.isEmpty &&
        bccEmails.isEmpty &&
        subject.isEmpty &&
        body.isEmpty &&
        widget.draft == null) {
      AppFunctions.debugPrint('Các trường rỗng, không lưu nháp');
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lưu thư nháp thất bại: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ComposeState(),
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final shouldPop = await handleBackAction();
          if (shouldPop && context.mounted) {
            Navigator.pop(context);
          }
        },
        child: Scaffold(
          appBar: ComposeAppBar(
            onSendEmail: handleSendEmail,
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
            bodyController: bodyController,
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
    bodyController.dispose();
    super.dispose();
  }
}
