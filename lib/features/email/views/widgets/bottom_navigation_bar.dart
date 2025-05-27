import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/providers/theme_manage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomNavigationBarWidget extends StatefulWidget {
  const BottomNavigationBarWidget({
    required this.selectedIndex,
    required this.emailService,
    required this.onItemTapped,
    super.key,
  });

  final int selectedIndex;
  final EmailService emailService;
  final void Function(int) onItemTapped;

  @override
  State<BottomNavigationBarWidget> createState() =>
      _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeManage>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final iconColor = isDarkMode ? Colors.white70 : Colors.grey[800];
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white70;
    final badgeBackgroundColor = isDarkMode ? Colors.red[700] : Colors.red[500];
    const badgeTextColor = Colors.white;
    final selectedItemColor = Theme.of(context).colorScheme.primary;

    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: FutureBuilder<int>(
            future: widget.emailService.countUnreadEmails(),
            builder: (context, snapshot) {
              final icon = Icon(
                widget.selectedIndex == 0
                    ? Icons.mail_rounded
                    : Icons.mail_outline,
                color: iconColor,
                size: 26,
              );
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Badge(
                  label: const Text(
                    '...',
                    style: TextStyle(color: badgeTextColor),
                  ),
                  backgroundColor: badgeBackgroundColor,
                  child: icon,
                );
              }
              if (snapshot.hasError) {
                return Badge(
                  label: const Text(
                    'Err',
                    style: TextStyle(color: badgeTextColor),
                  ),
                  backgroundColor: badgeBackgroundColor,
                  child: icon,
                );
              }
              if (snapshot.data != null && snapshot.data! > 0) {
                return Badge(
                  label: Text(
                    snapshot.data.toString(),
                    style: const TextStyle(color: badgeTextColor),
                  ),
                  backgroundColor: badgeBackgroundColor,
                  child: icon,
                );
              }
              return icon;
            },
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            widget.selectedIndex == 1
                ? Icons.videocam_sharp
                : Icons.videocam_outlined,
            color: iconColor,
            size: 26,
          ),
          label: '',
        ),
      ],
      currentIndex: widget.selectedIndex,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: iconColor,
      onTap: widget.onItemTapped,
      backgroundColor: backgroundColor,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      elevation: 8,
    );
  }
}
