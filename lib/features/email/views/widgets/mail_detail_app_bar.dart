import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:flutter/material.dart';

class MailDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MailDetailAppBar({
    required this.email,
    required this.emailService,
    this.onRefresh,
    super.key,
  });

  final Email email;
  final EmailService emailService;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white70),
        onPressed: () {
          onRefresh?.call();
          Navigator.pop(context);
        },
      ),
      backgroundColor: Colors.grey[900],
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.white70),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(
            Icons.mark_email_unread_outlined,
            color: Colors.white70,
          ),
          onPressed: () async {
            try {
              await emailService.toggleRead(email.id, email.read);
              onRefresh?.call();
              Navigator.pop(context);
            } on Exception catch (e) {
              print('Lỗi khi chuyển trạng thái đã đọc: $e');
            }
          },
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.more_horiz, color: Colors.white70),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
