import 'package:email_application/core/constants/app_strings.dart';
import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/views/screens/compose_screen.dart';
import 'package:email_application/features/email/views/widgets/compose_button.dart';
import 'package:email_application/features/email/views/widgets/email_list.dart';
import 'package:email_application/features/email/views/widgets/gmail_app_bar.dart';
import 'package:email_application/features/email/views/widgets/gmail_drawer.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
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
                MaterialPageRoute(builder: (context) => const ComposeScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
