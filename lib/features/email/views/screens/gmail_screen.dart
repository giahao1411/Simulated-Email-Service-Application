import 'package:email_application/core/constants/app_strings.dart';
import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/providers/theme_manage.dart';
import 'package:email_application/features/email/views/screens/compose_screen.dart';
import 'package:email_application/features/email/views/widgets/compose_button.dart';
import 'package:email_application/features/email/views/widgets/email_list.dart';
import 'package:email_application/features/email/views/widgets/gmail_app_bar.dart';
import 'package:email_application/features/email/views/widgets/gmail_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GmailScreen extends StatefulWidget {
  const GmailScreen({super.key});

  @override
  State<GmailScreen> createState() => _GmailScreenState();
}

class _GmailScreenState extends State<GmailScreen>
    with SingleTickerProviderStateMixin {
  bool isDrawerOpen = false;
  String currentCategory = AppStrings.inbox;
  final EmailService emailService = EmailService();
  late Stream<List<Email>> emailStream;

  @override
  void initState() {
    super.initState();
    _refreshStream();
  }

  void _refreshStream() {
    setState(() {
      emailStream = emailService.getEmails(currentCategory).asBroadcastStream();
    });
  }

  void toggleDrawer() {
    setState(() {
      isDrawerOpen = !isDrawerOpen;
    });
  }

  void setCategory(String category) {
    setState(() {
      currentCategory = category;
      isDrawerOpen = false;
      _refreshStream();
    });
  }

  Future<int> countUnreadMails() {
    return emailService.countUnreadEmails();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeManage>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final textIconTheme = isDarkMode ? Colors.white70 : Colors.grey[800];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              GmailAppBar(onMenuPressed: toggleDrawer),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    currentCategory,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: EmailList(
                  emailService: emailService,
                  currentCategory: currentCategory,
                  emailStream: emailStream,
                  onRefresh: _refreshStream,
                ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 16),
                color: isDarkMode ? Colors.grey[900] : Colors.white70,
                child: _unreadMailRemainingIcon(textIconTheme!),
              ),
            ],
          ),
          if (isDrawerOpen)
            GestureDetector(
              onTap: toggleDrawer,
              child: Container(color: Colors.black54),
            ),
          if (isDrawerOpen)
            GmailDrawer(
              currentCategory: currentCategory,
              onCategorySelected: setCategory,
            ),
          ComposeButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const ComposeScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _unreadMailRemainingIcon(Color iconColor) {
    final icon = Icon(Icons.mail_outline, color: iconColor, size: 26);

    return FutureBuilder<int>(
      future: countUnreadMails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Badge(label: const Text('...'), child: icon);
        }
        if (snapshot.hasError) {
          return Badge(label: const Text('Err'), child: icon);
        }
        if (snapshot.data != null && snapshot.data! > 0) {
          return Badge(label: Text(snapshot.data.toString()), child: icon);
        }
        return icon;
      },
    );
  }
}
