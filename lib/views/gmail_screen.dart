import 'package:flutter/material.dart';
import '../controllers/email_service.dart';
import '../models/email.dart';
import 'compose_screen.dart';
import 'settings_screen.dart';

class GmailScreen extends StatefulWidget {
  const GmailScreen({Key? key}) : super(key: key);

  @override
  State<GmailScreen> createState() => _GmailScreenState();
}

class _GmailScreenState extends State<GmailScreen>
    with SingleTickerProviderStateMixin {
  bool isDrawerOpen = false;
  String currentCategory = "Hộp thư đến";
  final EmailService emailService = EmailService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 16,
                  right: 16,
                  bottom: 8,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 0),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 2,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  height: 50,
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            isDrawerOpen = true;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Tìm trong thư",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.teal,
                          backgroundImage: NetworkImage(
                            'https://picsum.photos/250?image=100',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    currentCategory,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.grey[900],
                  child: StreamBuilder<List<Email>>(
                    stream: emailService.getEmails(currentCategory),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            "Không có email",
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                      var emails = snapshot.data!;
                      return ListView.builder(
                        padding: const EdgeInsets.all(0),
                        itemCount: emails.length,
                        itemBuilder: (context, index) {
                          var email = emails[index];
                          return _buildEmailTile(email: email, index: index);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          if (isDrawerOpen)
            GestureDetector(
              onTap: () {
                setState(() {
                  isDrawerOpen = false;
                });
              },
              child: Container(color: Colors.black54),
            ),
          if (isDrawerOpen)
            Container(
              width: MediaQuery.of(context).size.width * 0.7,
              color: Colors.grey[850],
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 16,
                      right: 16,
                      bottom: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey[800]!,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Gmail_icon_%282020%29.svg/1280px-Gmail_icon_%282020%29.svg.png',
                          width: 30,
                          height: 30,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Gmail',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _buildDrawerItem(
                          "Hộp thư đến",
                          Icons.inbox,
                          isSelected: currentCategory == "Hộp thư đến",
                        ),
                        _buildDrawerItem(
                          "Có gắn dấu sao",
                          Icons.star_border,
                          isSelected: currentCategory == "Có gắn dấu sao",
                        ),
                        _buildDrawerItem(
                          "Đã gửi",
                          Icons.send,
                          isSelected: currentCategory == "Đã gửi",
                        ),
                        _buildDrawerItem(
                          "Thư nháp",
                          Icons.insert_drive_file,
                          count: 10,
                        ),
                        _buildDrawerItem("Thùng rác", Icons.delete),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(
                            color: Colors.grey[700],
                            height: 1,
                            thickness: 1,
                            indent: 52,
                            endIndent: 16,
                          ),
                        ),
                        _buildDrawerItem("Cài đặt", Icons.settings),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Positioned(
            bottom: 66,
            right: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ComposeScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_outlined, color: Colors.red[200], size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Soạn thư",
                      style: TextStyle(color: Colors.red[200], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailTile({required Email email, required int index}) {
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

  Widget _buildDrawerItem(
    String title,
    IconData icon, {
    Color? color,
    bool isSelected = false,
    int? count,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 12, top: 2, bottom: 2),
      child: Container(
        decoration:
            isSelected
                ? BoxDecoration(
                  color: Colors.red[200]!.withOpacity(0.2),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                )
                : null,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Icon(
            icon,
            color: color ?? (isSelected ? Colors.red[200] : Colors.grey),
            size: 16,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.red[200] : Colors.white,
              fontSize: 14,
            ),
          ),
          trailing:
              count != null
                  ? Text(
                    count.toString(),
                    style: const TextStyle(color: Colors.grey),
                  )
                  : null,
          selected: isSelected,
          onTap: () {
            setState(() {
              currentCategory = title;
              isDrawerOpen = false;
              if (title == "Cài đặt") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              }
            });
          },
        ),
      ),
    );
  }
}
