import 'package:email_application/features/email/models/email_search_result.dart';
import 'package:flutter/material.dart';

class EmailSearchItem extends StatelessWidget {
  const EmailSearchItem({
    required this.result,
    required this.searchQuery,
    required this.onTap,
    super.key,
  });

  final EmailSearchResult result;
  final String searchQuery;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final onSurface60 = onSurface.withOpacity(0.6);
    final onSurface70 = onSurface.withOpacity(0.7);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color:
                  isDarkMode
                      ? Colors.grey[700]!
                      : theme.dividerColor.withOpacity(0.3),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(context),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          result.senderName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        result.time,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: onSurface60,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          result.subject,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (result.isImportant)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isDarkMode
                                    ? Colors.orange.shade800
                                    : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Hộp thư đến',
                            style: TextStyle(
                              fontSize: 10,
                              color:
                                  isDarkMode
                                      ? Colors.orange.shade100
                                      : Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result.preview,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: onSurface70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                result.isStarred ? Icons.star : Icons.star_border,
                color:
                    result.isStarred
                        ? Colors.amber
                        : (isDarkMode ? Colors.grey[400] : Colors.grey),
                size: 20,
              ),
              onPressed: () {
                print('Toggle star for: ${result.subject}');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (result.avatarUrl != null && result.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(result.avatarUrl!),
      );
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor:
          result.backgroundColor ??
          (isDarkMode ? Colors.grey[700] : Colors.grey),
      child:
          result.avatarText != null
              ? Text(
                result.avatarText!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              )
              : Icon(Icons.person, color: Colors.white, size: 20),
    );
  }
}
