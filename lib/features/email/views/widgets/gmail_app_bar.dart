import 'dart:io';

import 'package:email_application/core/constants/app_strings.dart';
import 'package:email_application/features/email/controllers/auth_service.dart';
import 'package:email_application/features/email/models/user_profile.dart';
import 'package:flutter/material.dart';

class GmailAppBar extends StatelessWidget {
  const GmailAppBar({required this.onMenuPressed, super.key});
  final VoidCallback onMenuPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[850],
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
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: onMenuPressed,
            ),
            const SizedBox(width: 8),
            const Text(
              AppStrings.searchInMail,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const Spacer(),
            FutureBuilder<UserProfile?>(
              future: AuthService().currentUser,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.amberAccent,
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.amberAccent,
                      child: Text(
                        '?',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  );
                }

                final userProfile = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.amberAccent,
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
                            ? const Text(
                              '?',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
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
