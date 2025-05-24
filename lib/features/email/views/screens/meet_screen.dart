import 'package:email_application/core/constants/app_strings.dart';
import 'package:email_application/features/email/controllers/auth_service.dart';
import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/user_profile.dart';
import 'package:email_application/features/email/views/screens/gmail_screen.dart';
import 'package:email_application/features/email/views/widgets/bottom_navigation_bar.dart';
import 'package:email_application/features/email/views/widgets/gmail_drawer.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class MeetScreen extends StatefulWidget {
  const MeetScreen({super.key});

  @override
  State<MeetScreen> createState() => _MeetScreenState();
}

class _MeetScreenState extends State<MeetScreen> {
  bool isDrawerOpen = false;
  String currentCategory = AppStrings.meet;
  final EmailService emailService = EmailService();
  int _selectedIndex = 1;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
    });
    if (category != AppStrings.meet) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (context) => const GmailScreen()),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (context) => const GmailScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    top: 16,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.menu,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 24,
                        ),
                        onPressed: toggleDrawer,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Họp mặt',
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      FutureBuilder<UserProfile?>(
                        future: AuthService().currentUser,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircleAvatar(
                              radius: 18,
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                            );
                          }
                          if (snapshot.hasError || !snapshot.hasData) {
                            return CircleAvatar(
                              radius: 18,
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              child: Text(
                                '?',
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                            );
                          }

                          final userProfile = snapshot.data!;
                          return CircleAvatar(
                            radius: 18,
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            backgroundImage:
                                userProfile.photoUrl != null &&
                                        userProfile.photoUrl!.isNotEmpty
                                    ? (userProfile.photoUrl!.startsWith('http')
                                        ? NetworkImage(userProfile.photoUrl!)
                                            as ImageProvider
                                        : FileImage(File(userProfile.photoUrl!))
                                            as ImageProvider)
                                    : null,
                            child:
                                userProfile.photoUrl == null ||
                                        userProfile.photoUrl!.isEmpty
                                    ? Text(
                                      '?',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSecondary,
                                      ),
                                    )
                                    : null,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[100],
                            foregroundColor: Colors.blue[800],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Cuộc họp mới',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.onSurface,
                            side: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.3),
                              width: 1,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Tham gia bằng mã',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    child: PageView(
                      controller: _pageController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        _buildPage(
                          context,
                          imagePath: 'assets/images/meet_link.png',
                          title: 'Nhận đường liên kết bạn có thể chia sẻ',
                          description:
                              'Nhấn vào Cuộc họp mới để nhận một đường liên kết mà bạn có thể gửi cho những người mà bạn muốn họp cùng',
                        ),
                        _buildPage(
                          context,
                          imagePath: 'assets/images/meet_private.png',
                          title: 'Cuộc họp luôn an toàn',
                          description:
                              'Không ai có thể tham gia cuộc họp trừ phi được người tổ chức mời hoặc cho phép',
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(2, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        width: _currentPage == index ? 12.0 : 8.0,
                        height: 8.0,
                        decoration: BoxDecoration(
                          color:
                              _currentPage == index
                                  ? Colors.blue
                                  : Colors.grey.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBarWidget(
            selectedIndex: _selectedIndex,
            emailService: emailService,
            onItemTapped: _onItemTapped,
          ),
        ),
        // Overlay drawer that covers everything including bottom navigation
        if (isDrawerOpen) ...[
          // Background overlay
          GestureDetector(
            onTap: toggleDrawer,
            child: Container(
              color: Colors.black54,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          // Drawer widget positioned above everything
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Material(
              elevation: 16,
              child: Container(
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

  Widget _buildPage(
    BuildContext context, {
    required String imagePath,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 1),
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(0.1),
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.withOpacity(0.2),
                    ),
                    child: Icon(Icons.video_call, size: 80, color: Colors.blue),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 16,
              height: 1.4,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
