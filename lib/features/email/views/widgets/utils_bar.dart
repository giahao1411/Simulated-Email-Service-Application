import 'package:email_application/features/email/models/email.dart';
import 'package:flutter/material.dart';

class UtilsBar extends StatelessWidget {
  const UtilsBar({
    required this.email,
    required this.onSurface60,
    required this.sendReply,
    required this.sendReplyAll,
    required this.sendForward,
    super.key,
  });

  final Email email;
  final Color onSurface60;
  final VoidCallback sendReply;
  final VoidCallback sendReplyAll;
  final VoidCallback? sendForward;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          OverflowBar(
            alignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: email.from.isEmpty ? null : sendReply,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: onSurface60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.reply, color: onSurface60),
                    const SizedBox(width: 4),
                    Text('Phản hồi', style: TextStyle(color: onSurface60)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (email.cc.isNotEmpty)
                OutlinedButton(
                  onPressed: email.from.isEmpty ? null : sendReplyAll,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: onSurface60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.reply_all, color: onSurface60),
                      const SizedBox(width: 4),
                      Text(
                        'Phản hồi tất cả',
                        style: TextStyle(color: onSurface60),
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: sendForward,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: onSurface60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.forward, color: onSurface60),
                    const SizedBox(width: 4),
                    Text('Chuyển tiếp', style: TextStyle(color: onSurface60)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [SizedBox.shrink()],
          ),
        ],
      ),
    );
  }
}
