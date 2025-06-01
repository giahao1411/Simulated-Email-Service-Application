import 'package:email_application/features/email/providers/theme_manage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FilterChipWidget extends StatelessWidget {
  const FilterChipWidget({
    required this.label,
    required this.onTap,
    this.value,
    this.onDeleted,
    super.key,
  });

  final String label;
  final String? value;
  final VoidCallback onTap;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeManage>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final backgroundColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final textColor = isDarkMode ? Colors.white70 : Colors.black87;
    final iconColor = isDarkMode ? Colors.white70 : Colors.black54;
    final actionColor = Theme.of(context).colorScheme.primary;
    final isSelected = value != null && value!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? (isDarkMode
                      ? actionColor.withOpacity(0.2)
                      : actionColor.withOpacity(0.1))
                  : backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isSelected ? value! : label,
              style: TextStyle(
                color:
                    isSelected
                        ? (isDarkMode
                            ? actionColor.withOpacity(0.7)
                            : actionColor.withOpacity(0.9))
                        : textColor,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color:
                  isSelected
                      ? (isDarkMode
                          ? actionColor.withOpacity(0.7)
                          : actionColor.withOpacity(0.9))
                      : iconColor,
            ),
            if (isSelected && onDeleted != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDeleted,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color:
                      isSelected
                          ? (isDarkMode
                              ? actionColor.withOpacity(0.7)
                              : actionColor.withOpacity(0.9))
                          : iconColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
