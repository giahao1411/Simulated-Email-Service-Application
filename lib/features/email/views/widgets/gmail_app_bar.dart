import 'dart:io';
import 'package:email_application/core/constants/app_strings.dart';
import 'package:email_application/features/email/controllers/auth_service.dart';
import 'package:email_application/features/email/models/user_profile.dart';
import 'package:email_application/features/email/views/screens/search_screen.dart';
import 'package:flutter/material.dart';

class GmailAppBar extends StatelessWidget {
  const GmailAppBar({
    required this.onMenuPressed,
    required this.currentCategory,
    super.key,
  });

  final VoidCallback onMenuPressed;
  final String currentCategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
            ),
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2),
          ],
        ),
        height: 50,
        child: Row(
          children: [
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.menu,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: onMenuPressed,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<SearchScreen>(
                      builder:
                          (context) =>
                              SearchScreen(currentCategory: currentCategory),
                    ),
                  );
                },
                child: Container(
                  height: double.infinity,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppStrings.searchInMail,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FutureBuilder<UserProfile?>(
              future: AuthService().currentUser,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: CircleAvatar(
                      radius: 16,
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
                    padding: const EdgeInsets.only(right: 12),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      child: Text(
                        '?',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ),
                    ),
                  );
                }
                final userProfile = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CircleAvatar(
                    radius: 16,
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
                    child:
                        userProfile.photoUrl == null ||
                                userProfile.photoUrl!.isEmpty
                            ? Text(
                              '?',
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                            )
                            : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
