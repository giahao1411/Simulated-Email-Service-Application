import 'package:email_application/core/constants/app_strings.dart';
import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/views/screens/compose_screen.dart';
import 'package:email_application/features/email/views/screens/meet_screen.dart';
import 'package:email_application/features/email/views/widgets/bottom_navigation_bar.dart';
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
  int _selectedIndex = 0;

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
      _refreshStream();
      isDrawerOpen = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (context) => const MeetScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Column(
            children: [
              GmailAppBar(
                onMenuPressed: toggleDrawer,
                currentCategory: currentCategory,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
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
                child: Stack(
                  children: [
                    EmailList(
                      emailService: emailService,
                      currentCategory: currentCategory,
                      emailStream: emailStream,
                      onRefresh: _refreshStream,
                      refreshStream: _refreshStream,
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
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBarWidget(
            selectedIndex: _selectedIndex,
            emailService: emailService,
            onItemTapped: _onItemTapped,
          ),
        ),
        if (isDrawerOpen) ...[
          GestureDetector(
            onTap: toggleDrawer,
            child: Container(
              color: Colors.black54,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Material(
              elevation: 16,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: GmailDrawer(
                  currentCategory: currentCategory,
                  onCategorySelected: setCategory,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
