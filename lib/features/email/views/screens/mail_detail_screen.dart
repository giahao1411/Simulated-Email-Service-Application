import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/models/email_state.dart';
import 'package:email_application/features/email/views/screens/foward_screen.dart';
import 'package:email_application/features/email/views/screens/gmail_screen.dart';
import 'package:email_application/features/email/views/screens/meet_screen.dart';
import 'package:email_application/features/email/views/screens/reply_screen.dart';
import 'package:email_application/features/email/views/widgets/bottom_navigation_bar.dart';
import 'package:email_application/features/email/views/widgets/mail_detail_app_bar.dart';
import 'package:email_application/features/email/views/widgets/mail_detail_body.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MailDetail extends StatefulWidget {
  const MailDetail({
    required this.email,
    required this.state,
    required this.senderFullName,
    this.onRefresh,
    super.key,
  });

  final Email email;
  final EmailState state;
  final String senderFullName;
  final VoidCallback? onRefresh;

  @override
  State<MailDetail> createState() => _MailDetailState();
}

class _MailDetailState extends State<MailDetail>
    with SingleTickerProviderStateMixin {
  final EmailService emailService = EmailService();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _markMailAsRead();
  }

  Future<void> _markMailAsRead() async {
    try {
      if (!widget.state.read) {
        await emailService.toggleRead(widget.email.id, widget.state.read);
        widget.onRefresh?.call();
      }
    } on Exception catch (e) {
      AppFunctions.debugPrint('Lỗi khi chuyển trạng thái đã đọc: $e');
    }
  }

  void _sendReply() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder:
            (context) => ReplyScreen(
              email: widget.email,
              state: widget.state,
              onRefresh: widget.onRefresh,
            ),
      ),
    );
  }

  void _sendForward() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder:
            (context) => ForwardScreen(
              email: widget.email,
              state: widget.state,
              onRefresh: widget.onRefresh,
            ),
      ),
    );
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Người dùng chưa đăng nhập'));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('email_states')
              .doc(widget.email.id)
              .snapshots(),
      builder: (context, stateSnapshot) {
        if (!stateSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final updatedState = EmailState.fromMap(
          stateSnapshot.data!.data() as Map<String, dynamic>? ?? {},
        );

        return StreamBuilder<DocumentSnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('emails')
                  .doc(widget.email.id)
                  .snapshots(),
          builder: (context, emailSnapshot) {
            if (!emailSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final updatedEmail = Email.fromMap(
              widget.email.id,
              emailSnapshot.data!.data()! as Map<String, dynamic>,
            );

            return Stack(
              children: [
                Scaffold(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  appBar: MailDetailAppBar(
                    email: updatedEmail,
                    state: updatedState,
                    emailService: emailService,
                    onRefresh: widget.onRefresh,
                  ),
                  body: Column(
                    children: [
                      Expanded(
                        child: MailDetailBody(
                          email: updatedEmail,
                          state: updatedState,
                          senderFullName: widget.senderFullName,
                          onRefresh: widget.onRefresh,
                          markMailAsRead: _markMailAsRead,
                          index: _selectedIndex,
                          sendReply: _sendReply,
                          sendForward: _sendForward,
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
          },
        );
      },
    );
  }
}
