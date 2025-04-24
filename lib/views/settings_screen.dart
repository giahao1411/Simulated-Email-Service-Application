import 'package:flutter/material.dart';
import '../controllers/auth_service.dart';
import '../controllers/profile_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService authService = AuthService();
  final ProfileService profileService = ProfileService();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isDarkMode = true;
  bool isAutoReply = false;

  Future<void> handleUpdateProfile() async {
    await profileService.updateProfile(displayNameController.text, null);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Cập nhật hồ sơ thành công")));
  }

  Future<void> handleChangePassword() async {
    try {
      await authService.changePassword(passwordController.text);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Đổi mật khẩu thành công")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lỗi khi đổi mật khẩu")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cài đặt")),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Chế độ tối"),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                setState(() {
                  isDarkMode = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text("Chế độ trả lời tự động"),
            trailing: Switch(
              value: isAutoReply,
              onChanged: (value) {
                setState(() {
                  isAutoReply = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: displayNameController,
              decoration: const InputDecoration(labelText: "Tên hiển thị"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: handleUpdateProfile,
              child: const Text("Cập nhật hồ sơ"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Mật khẩu mới"),
              obscureText: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: handleChangePassword,
              child: const Text("Đổi mật khẩu"),
            ),
          ),
        ],
      ),
    );
  }
}
