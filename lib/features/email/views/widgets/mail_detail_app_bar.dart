import 'package:email_application/core/constants/app_functions.dart';
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
    final theme = Theme.of(context);
    return AppBar(
      actionsPadding: const EdgeInsets.only(left: 16, right: 8),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
        onPressed: () {
          onRefresh?.call();
          Navigator.pop(context);
        },
      ),
      backgroundColor:
          theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
      actions: [
        IconButton(
          icon: Icon(Icons.delete_outline, color: theme.colorScheme.onSurface),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(
            Icons.mark_email_unread_outlined,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () async {
            try {
              await emailService.toggleRead(email.id, email.read);
              onRefresh?.call();
              Navigator.pop(context);
            } on Exception catch (e) {
              AppFunctions.debugPrint('Lỗi khi chuyển trạng thái đã đọc: $e');
            }
          },
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(Icons.more_horiz, color: theme.colorScheme.onSurface),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
