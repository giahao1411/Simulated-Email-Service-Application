import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/views/widgets/mail_detail_app_bar.dart';
import 'package:email_application/features/email/views/widgets/mail_detail_body.dart';
import 'package:flutter/material.dart';

class MailDetail extends StatefulWidget {
  const MailDetail({required this.email, this.onRefresh, super.key});

  final Email email;
  final VoidCallback? onRefresh;

  @override
  State<MailDetail> createState() => _MailDetailState();
}

class _MailDetailState extends State<MailDetail> {
  late Email email;
  final EmailService emailService = EmailService();

  @override
  void initState() {
    super.initState();
    email = widget.email;
    _markMailAsRead();
  }

  Future<void> _markMailAsRead() async {
    try {
      if (!email.read) {
        await emailService.toggleRead(email.id, email.read);
        setState(() {
          email = email.copyWith(read: true);
        });
      }
    } on Exception catch (e) {
      print('Lỗi khi chuyển trạng thái đã đọc: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MailDetailAppBar(
        email: email,
        emailService: emailService,
        onRefresh: widget.onRefresh,
      ),
      body: MailDetailBody(email: email, onRefresh: widget.onRefresh),
    );
  }
}
