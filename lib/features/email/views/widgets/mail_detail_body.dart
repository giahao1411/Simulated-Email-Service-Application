import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/utils/date_format.dart';
import 'package:flutter/material.dart';

class MailDetailBody extends StatefulWidget {
  MailDetailBody({required this.email, super.key});

  final Email email;
  final EmailService emailService = EmailService();

  @override
  State<MailDetailBody> createState() => _MailDetailBodyState();
}

class _MailDetailBodyState extends State<MailDetailBody> {
  late Email email;
  final EmailService emailService = EmailService();

  @override
  void initState() {
    super.initState();
    email = widget.email;
  }

  Future<int> countUnreadMails() {
    return emailService.countUnreadEmails();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // mail subject
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      email.subject,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        email.starred ? Icons.star : Icons.star_border,
                        color:
                            email.starred
                                ? Colors.amber
                                : Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                        size: 25,
                      ),
                      onPressed: () async {
                        await emailService.toggleStar(email.id, email.starred);
                        setState(() {
                          email = email.copyWith(starred: !email.starred);
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // sender information
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://via.placeholder.com/40',
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        email.from,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat.formatTimestamp(email.timestamp),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    'to bcc: ${email.bcc}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.reply),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_horiz),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  onTap: () {},
                ),

                // mail body
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    email.body,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ),

                // utils/icons
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey[900],
                  child: Column(
                    children: [
                      OverflowBar(
                        alignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('Reply'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('Forward'),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FutureBuilder<int>(
                            future: countUnreadMails(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Badge(
                                  label: const Text('...'),
                                  child: IconButton(
                                    icon: const Icon(Icons.mail),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                );
                              }
                              if (snapshot.hasError) {
                                return Badge(
                                  label: const Text('Err'),
                                  child: IconButton(
                                    icon: const Icon(Icons.mail),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                );
                              }
                              return Badge(
                                label: Text(snapshot.data.toString()),
                                child: IconButton(
                                  icon: const Icon(Icons.mail),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
