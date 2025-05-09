import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../controllers/email_service.dart';
import './widgets/gmail_app_bar.dart';
import './widgets/email_list.dart';
import './widgets/gmail_drawer.dart';
import './widgets/compose_button.dart';
import 'compose_screen.dart';

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

  void toggleDrawer() {
    setState(() {
      isDrawerOpen = !isDrawerOpen;
    });
  }

  void setCategory(String category) {
    setState(() {
      currentCategory = category;
      isDrawerOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Stack(
        children: [
          Column(
            children: [
              GmailAppBar(onMenuPressed: toggleDrawer),
              Expanded(
                child: EmailList(
                  emailService: emailService,
                  currentCategory: currentCategory,
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
