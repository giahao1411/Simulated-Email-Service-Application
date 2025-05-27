import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/models/email_state.dart';
import 'package:email_application/features/email/views/screens/gmail_screen.dart';
import 'package:email_application/features/email/views/screens/meet_screen.dart';
import 'package:email_application/features/email/views/widgets/bottom_navigation_bar.dart';
import 'package:email_application/features/email/views/widgets/mail_detail_app_bar.dart';
import 'package:email_application/features/email/views/widgets/mail_detail_body.dart';
import 'package:flutter/material.dart';

class MailDetail extends StatefulWidget {
  const MailDetail({
    required this.email,
    required this.state,
    this.onRefresh,
    super.key,
  });

  final Email email;
  final EmailState state;
  final VoidCallback? onRefresh;

  @override
  State<MailDetail> createState() => _MailDetailState();
}

class _MailDetailState extends State<MailDetail>
    with SingleTickerProviderStateMixin {
  late Email email;
  final EmailService emailService = EmailService();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    email = widget.email;
    _markMailAsRead();
  }

  Future<void> _markMailAsRead() async {
    try {
      if (!widget.state.read) {
        await emailService.toggleRead(email.id, widget.state.read);
        widget.onRefresh?.call();
      }
    } on Exception catch (e) {
      AppFunctions.debugPrint('Lỗi khi chuyển trạng thái đã đọc: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (context) => const GmailScreen()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (context) => const MeetScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: MailDetailAppBar(
            email: email,
            state: widget.state,
            emailService: emailService,
            onRefresh: widget.onRefresh,
          ),
          body: Column(
            children: [
              // Không cần danh sách email như GmailScreen, chỉ hiển thị chi tiết
              Expanded(
                child: MailDetailBody(
                  email: email,
                  state: widget.state,
                  onRefresh: widget.onRefresh,
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBarWidget(
            selectedIndex: _selectedIndex,
            emailService: emailService,
            onItemTapped: _onItemTapped,
          ),
        ),
      ],
    );
  }
}
