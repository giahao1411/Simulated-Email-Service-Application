import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MyGmail(),
    );
  }
}

class MyGmail extends StatefulWidget {
  const MyGmail({Key? key}) : super(key: key);

  @override
  State<MyGmail> createState() => _GmailHomePageState();
}

class _GmailHomePageState extends State<MyGmail>
    with SingleTickerProviderStateMixin {
  bool isDrawerOpen = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Stack(
        children: [
          Column(
            children: [
              // AppBar Search
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
                  child: const Text(
                    "Hộp thư đến",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

              // Email List
              Expanded(
                child: Container(
                  color: Colors.grey[900],
                  child: ListView(
                    padding: const EdgeInsets.all(0),
                    children: [
                      _buildEmailTile(
                        sender: "Google",
                        subject: "Security alert",
                        preview:
                            "A new sign-in on Windows 522h0090@student.tdtu.edu.vn We noticed a new sign-in to your Google Account on a Windows device. If this was you, you don't need to do anything. If not, we'll help you secure your account.",
                        date: "9 thg 3",
                        index: 1,
                      ),
                      _buildEmailTile(
                        sender: "Google",
                        subject: "Security alert",
                        preview:
                            "A new sign-in on Windows 522h0090@student.tdtu.edu.vn We noticed a new sign-in to your Google Account on a Windows device. If this was you, you don't need to do anything. If not, we'll help you secure your account.",
                        date: "9 thg 3",
                        index: 2,
                      ),
                      _buildEmailTile(
                        sender: "Google",
                        subject: "Security alert",
                        preview:
                            "A new sign-in on Windows 522h0090@student.tdtu.edu.vn We noticed a new sign-in to your Google Account on a Windows device. If this was you, you don't need to do anything. If not, we'll help you secure your account.",
                        date: "9 thg 3",
                        index: 3,
                      ),
                      _buildEmailTile(
                        sender: "Google",
                        subject: "Security alert",
                        preview:
                            "A new sign-in on Windows 522h0090@student.tdtu.edu.vn We noticed a new sign-in to your Google Account on a Windows device. If this was you, you don't need to do anything. If not, we'll help you secure your account.",
                        date: "9 thg 3",
                        index: 4,
                      ),
                      _buildEmailTile(
                        sender: "Google",
                        subject: "Security alert",
                        preview:
                            "A new sign-in on Windows 522h0090@student.tdtu.edu.vn We noticed a new sign-in to your Google Account on a Windows device. If this was you, you don't need to do anything. If not, we'll help you secure your account.",
                        date: "9 thg 3",
                        index: 5,
                      ),
                      _buildEmailTile(
                        sender: "Google",
                        subject: "Security alert",
                        preview:
                            "A new sign-in on Windows 522h0090@student.tdtu.edu.vn We noticed a new sign-in to your Google Account on a Windows device. If this was you, you don't need to do anything. If not, we'll help you secure your account.",
                        date: "9 thg 3",
                        index: 6,
                      ),
                      _buildEmailTile(
                        sender: "Google",
                        subject: "Security alert",
                        preview:
                            "A new sign-in on Windows 522h0090@student.tdtu.edu.vn We noticed a new sign-in to your Google Account on a Windows device. If this was you, you don't need to do anything. If not, we'll help you secure your account.",
                        date: "9 thg 3",
                        index: 7,
                      ),
                      _buildEmailTile(
                        sender: "Google",
                        subject: "Security alert",
                        preview:
                            "A new sign-in on Windows 522h0090@student.tdtu.edu.vn We noticed a new sign-in to your Google Account on a Windows device. If this was you, you don't need to do anything. If not, we'll help you secure your account.",
                        date: "9 thg 3",
                        index: 8,
                      ),
                      _buildEmailTile(
                        sender: "Google",
                        subject: "Security alert",
                        preview:
                            "A new sign-in on Windows 522h0090@student.tdtu.edu.vn We noticed a new sign-in to your Google Account on a Windows device. If this was you, you don't need to do anything. If not, we'll help you secure your account.",
                        date: "9 thg 3",
                        index: 9,
                      ),
                      _buildEmailTile(
                        sender: "Google",
                        subject: "Security alert",
                        preview:
                            "A new sign-in on Windows 522h0090@student.tdtu.edu.vn We noticed a new sign-in to your Google Account on a Windows device. If this was you, you don't need to do anything. If not, we'll help you secure your account.",
                        date: "9 thg 3",
                        index: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Navigation Drawer
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
                          "Đang hoạt động",
                          Icons.circle,
                          color: Colors.greenAccent,
                          trailing: Icon(
                            Icons.keyboard_arrow_up_outlined,
                            color: Colors.grey,
                            size: 24,
                          ),
                        ),
                        _buildDrawerItem(
                          "Thêm trạng thái",
                          Icons.edit_outlined,
                        ),
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
                        _buildDrawerItem("Tất cả hộp thư đến", Icons.all_inbox),
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
                        _buildDrawerItem(
                          "Hộp thư đến",
                          Icons.inbox,
                          isSelected: true,
                        ),
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
                        _buildDrawerItem("Có gắn dấu sao", Icons.star_border),
                        _buildDrawerItem("Đã ẩn", Icons.access_time),
                        _buildDrawerItem(
                          "Quan trọng",
                          Icons.label_important_outline,
                        ),
                        _buildDrawerItem("Đã gửi", Icons.send),
                        _buildDrawerItem("Đã lên lịch", Icons.schedule),
                        _buildDrawerItem("Hộp thư đi", Icons.outbox),
                        _buildDrawerItem(
                          "Thư nháp",
                          Icons.insert_drive_file,
                          count: 10,
                        ),
                        _buildDrawerItem("Tất cả thư", Icons.mail),
                        _buildDrawerItem("Thư rác", Icons.report_gmailerrorred),
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
                        _buildDrawerItem("Tạo mới", Icons.add),
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
                        _buildDrawerItem(
                          "Gửi ý kiến phản hồi",
                          Icons.feedback_outlined,
                        ),
                        _buildDrawerItem("Trợ giúp", Icons.help_outline),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Bottom Navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.grey[800],
              height: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.mail,
                      color: Color.fromARGB(255, 196, 102, 110),
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.grey,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.videocam_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),

          // Button Soan Thu
          Positioned(
            bottom: 66,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
        ],
      ),
    );
  }

  Widget _buildEmailTile({
    required String sender,
    required String subject,
    required String preview,
    required String date,
    required int index,
    bool hasAvatar = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child:
                hasAvatar
                    ? CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        'https://picsum.photos/250?image=$index',
                      ),
                    )
                    : CircleAvatar(
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
                    Text(sender, style: const TextStyle(color: Colors.grey)),
                    Text(
                      date,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subject,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star_border, color: Colors.grey, size: 20),
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
    Widget? trailing,
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
              trailing ??
              (count != null
                  ? Text(
                    count.toString(),
                    style: const TextStyle(color: Colors.grey),
                  )
                  : null),
          selected: isSelected,
        ),
      ),
    );
  }
}
