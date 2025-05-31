import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/draft.dart';
import 'package:email_application/features/email/models/email_state.dart';
import 'package:email_application/features/email/utils/date_format.dart';
import 'package:email_application/features/email/controllers/auth_service.dart';
import 'package:email_application/features/email/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class DraftTile extends StatelessWidget {
  const DraftTile({
    required this.draft,
    required this.state,
    required this.index,
    required this.emailService,
    this.onStarToggled,
    this.onTap,
    super.key,
  });

  final Draft draft;
  final EmailState state;
  final int index;
  final EmailService emailService;
  final VoidCallback? onStarToggled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<UserProfile?>(
              future: AuthService().currentUser,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.onSecondary,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                  );
                }
                final userProfile = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    backgroundImage:
                        userProfile.photoUrl != null &&
                                userProfile.photoUrl!.isNotEmpty
                            ? (userProfile.photoUrl!.startsWith('http')
                                ? NetworkImage(userProfile.photoUrl!)
                                    as ImageProvider
                                : FileImage(File(userProfile.photoUrl!))
                                    as ImageProvider)
                            : null,
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          draft.to.isNotEmpty
                              ? draft.to.join(', ')
                              : 'Thư nháp',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            color:
                                draft.to.isNotEmpty
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Colors.red,
                          ),
                        ),
                      ),
                      Text(
                        DateFormat.formatTimestamp(draft.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (draft.subject.isNotEmpty || draft.body.isNotEmpty) ...[
                    Text(
                      draft.subject.isEmpty
                          ? '(không có chủ đề)'
                          : draft.subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (draft.body.isNotEmpty) ...[
                        Expanded(
                          child: Text(
                            draft.body,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 2),
                      SizedBox(
                        width: 22,
                        height: 26,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              state.starred ? Icons.star : Icons.star_outline,
                              color:
                                  state.starred
                                      ? Colors.amber
                                      : Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.6),
                              size: 25,
                            ),
                            onPressed: () async {
                              try {
                                await emailService.toggleStar(
                                  draft.id,
                                  state.starred,
                                );
                                onStarToggled?.call();
                              } on Exception catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Lỗi: $e')),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
