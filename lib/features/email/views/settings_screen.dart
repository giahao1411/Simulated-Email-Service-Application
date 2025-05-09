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
  bool isTwoStepEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await profileService.getProfile();
    if (profile != null) {
      setState(() {
        displayNameController.text = profile.displayName ?? '';
        // Giả sử Firestore lưu trạng thái xác minh hai bước
        // Cần kiểm tra Firestore để lấy giá trị thực tế
        isTwoStepEnabled = false; // Thay bằng logic thực tế nếu có
      });
    }
  }

  Future<void> handleUpdateProfile() async {
    try {
      await profileService.updateProfile(displayNameController.text, null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật hồ sơ thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lỗi khi cập nhật hồ sơ')));
    }
  }

  Future<void> handleChangePassword() async {
    try {
      await authService.changePassword(passwordController.text);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đổi mật khẩu thành công')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lỗi khi đổi mật khẩu')));
    }
  }

  Future<void> handleToggleTwoStep(bool value) async {
    try {
      await authService.enableTwoStepVerification(value);
      setState(() {
        isTwoStepEnabled = value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật xác minh hai bước thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi cập nhật xác minh hai bước')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: [
          // Thông tin hồ sơ
          ListTile(
            title: const Text('Email'),
            subtitle: Text(user?.email ?? 'Chưa có email'),
          ),
          ListTile(
            title: const Text('Số điện thoại'),
            subtitle: Text(user?.phoneNumber ?? 'Chưa có số điện thoại'),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: displayNameController,
              decoration: const InputDecoration(labelText: 'Tên hiển thị'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: handleUpdateProfile,
              child: const Text('Cập nhật hồ sơ'),
            ),
          ),
          // Đổi mật khẩu
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
              obscureText: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: handleChangePassword,
              child: const Text('Đổi mật khẩu'),
            ),
          ),
          // Chế độ tối
          ListTile(
            title: const Text('Chế độ tối'),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                setState(() {
                  isDarkMode = value;
                });
              },
            ),
          ),
          // Trả lời tự động
          ListTile(
            title: const Text('Trả lời tự động'),
            trailing: Switch(
              value: isAutoReply,
              onChanged: (value) {
                setState(() {
                  isAutoReply = value;
                });
              },
            ),
          ),
          // Xác minh hai bước
          ListTile(
            title: const Text('Xác minh hai bước'),
            trailing: Switch(
              value: isTwoStepEnabled,
              onChanged: handleToggleTwoStep,
            ),
          ),
        ],
      ),
    );
  }
}
