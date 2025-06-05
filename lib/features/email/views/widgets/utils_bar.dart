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
    final showReplyAll = email.cc.isNotEmpty;
    final useColumnLayout = showReplyAll;

    return Container(
      padding: const EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: email.from.isEmpty ? null : sendReply,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: onSurface60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: const Size(80, 60),
                ),
                child:
                    useColumnLayout
                        ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.reply, color: onSurface60, size: 24),
                            const SizedBox(height: 4),
                            Text(
                              'Phản hồi',
                              style: TextStyle(color: onSurface60),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                        : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.reply, color: onSurface60, size: 24),
                            const SizedBox(width: 2),
                            Text(
                              'Phản hồi',
                              style: TextStyle(color: onSurface60),
                            ),
                          ],
                        ),
              ),
              if (showReplyAll)
                OutlinedButton(
                  onPressed: email.from.isEmpty ? null : sendReplyAll,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: onSurface60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    minimumSize: const Size(80, 60),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.reply_all, color: onSurface60, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        'Phản hồi tất cả',
                        style: TextStyle(color: onSurface60),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              OutlinedButton(
                onPressed: sendForward,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: onSurface60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: const Size(80, 60),
                ),
                child:
                    useColumnLayout
                        ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.forward, color: onSurface60, size: 24),
                            const SizedBox(height: 4),
                            Text(
                              'Chuyển tiếp',
                              style: TextStyle(color: onSurface60),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                        : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.forward, color: onSurface60, size: 24),
                            const SizedBox(width: 2),
                            Text(
                              'Chuyển tiếp',
                              style: TextStyle(color: onSurface60),
                            ),
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
