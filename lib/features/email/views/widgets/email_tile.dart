import 'package:flutter/material.dart';
import '../../controllers/email_service.dart';
import '../../models/email.dart';

class EmailTile extends StatelessWidget {
  final Email email;
  final int index;

  const EmailTile({super.key, required this.email, required this.index});

  @override
  Widget build(BuildContext context) {
    final emailService = EmailService();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                'https://picsum.photos/250?image=$index',
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      email.from,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      email.timestamp.toString().substring(0, 10),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  email.subject,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        email.body,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        email.starred ? Icons.star : Icons.star_border,
                        color: email.starred ? Colors.yellow : Colors.grey,
                        size: 20,
                      ),
                      onPressed:
                          () =>
                              emailService.toggleStar(email.id, email.starred),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
