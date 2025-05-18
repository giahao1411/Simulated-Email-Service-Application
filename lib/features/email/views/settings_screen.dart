import 'package:email_application/features/email/controllers/auth_service.dart';
import 'package:email_application/features/email/controllers/profile_service.dart';
import 'package:email_application/features/email/controllers/settings_controller.dart';
import 'package:email_application/features/email/models/user_profile.dart';
import 'package:email_application/features/email/views/widgets/profile_avatar.dart';
import 'package:email_application/features/email/views/widgets/profile_field.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SettingsController(
      authService: AuthService(),
      profileService: ProfileService(),
      firstNameController: TextEditingController(),
      lastNameController: TextEditingController(),
      passwordController: TextEditingController(),
    );
    _controller.loadPreferences();
    _controller.loadProfile().then((_) {
      if (mounted) setState(() {}); // Cập nhật UI sau khi loadProfile hoàn tất
    });
  }

  @override
  void dispose() {
    _controller.savePreferences();
    _controller.firstNameController.dispose();
    _controller.lastNameController.dispose();
    _controller.passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: _controller.authService.currentUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(
            child: Text('Lỗi khi tải thông tin người dùng hoặc chưa đăng nhập'),
          );
        }

        final user =
            snapshot.data; // An toàn để dùng ! vì đã kiểm tra snapshot.hasData
        return Scaffold(
          appBar: AppBar(
            title: const Text('Cài đặt'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Column(
                  children: [
                    ProfileAvatar(
                      controller: _controller,
                      isLoading: _controller.isLoading,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              ProfileField(controller: _controller, user: user!),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed:
                      _controller.isLoading
                          ? null
                          : () => _controller.updateProfile(context),
                  child:
                      _controller.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Cập nhật hồ sơ',
                            style: TextStyle(fontSize: 16),
                          ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextField(
                  controller: _controller.passwordController,
                  decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
                  obscureText: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed:
                      _controller.isLoading
                          ? null
                          : () => _controller.changePassword(context),
                  child:
                      _controller.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Đổi mật khẩu',
                            style: TextStyle(fontSize: 16),
                          ),
                ),
              ),
              ListTile(
                title: const Text('Chế độ tối'),
                trailing: Switch(
                  value: _controller.isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      _controller.isDarkMode = value;
                    });
                    _controller.savePreferences();
                  },
                ),
              ),
              ListTile(
                title: const Text('Trả lời tự động'),
                trailing: Switch(
                  value: _controller.isAutoReply,
                  onChanged: (value) {
                    setState(() {
                      _controller.isAutoReply = value;
                    });
                    _controller.savePreferences();
                  },
                ),
              ),
              ListTile(
                title: const Text('Xác minh hai bước'),
                trailing: Switch(
                  value: _controller.isTwoStepEnabled,
                  onChanged:
                      _controller.isLoading
                          ? null
                          : (value) =>
                              _controller.toggleTwoStep(context, value),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed:
                      _controller.isLoading
                          ? null
                          : () => _controller.signOut(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child:
                      _controller.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Đăng xuất',
                            style: TextStyle(fontSize: 16),
                          ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
