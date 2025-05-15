import 'package:email_application/features/email/controllers/auth_service.dart';
import 'package:email_application/features/email/controllers/profile_service.dart';
import 'package:email_application/features/email/models/user_profile.dart';
import 'package:email_application/features/email/views/login_screen.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService authService = AuthService();
  final ProfileService profileService = ProfileService();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isDarkMode = false;
  bool isAutoReply = false;
  bool isTwoStepEnabled = false;
  bool isLoading = false;
  UserProfile? userProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await profileService.getProfile();
      if (profile != null) {
        setState(() {
          firstNameController.text = profile.firstName ?? '';
          lastNameController.text = profile.lastName ?? '';
          isTwoStepEnabled = profile.twoStepEnabled ?? false;
          userProfile = profile;
        });
      }
    } catch (e) {
      print('Lỗi khi tải hồ sơ: $e');
      _showSnackBar('Lỗi khi tải hồ sơ: $e', false);
    }
  }

  Future<void> handleUpdateProfile() async {
    setState(() {
      isLoading = true;
    });
    try {
      await profileService.updateProfile(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
      );
      _showSnackBar('Cập nhật hồ sơ thành công', true);
    } catch (e) {
      _showSnackBar('Lỗi khi cập nhật hồ sơ: $e', false);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> handleChangePassword() async {
    setState(() {
      isLoading = true;
    });
    try {
      if (passwordController.text.isEmpty) {
        _showSnackBar('Vui lòng nhập mật khẩu mới', false);
        return;
      }
      await authService.changePassword(passwordController.text);
      _showSnackBar('Đổi mật khẩu thành công', true);
      passwordController.clear();
    } catch (e) {
      _showSnackBar('Lỗi khi đổi mật khẩu: $e', false);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> handleToggleTwoStep(bool value) async {
    setState(() {
      isLoading = true;
    });
    try {
      await authService.enableTwoStepVerification(value);
      setState(() {
        isTwoStepEnabled = value;
      });
      _showSnackBar('Cập nhật xác minh hai bước thành công', true);
    } catch (e) {
      _showSnackBar('Lỗi khi cập nhật xác minh hai bước: $e', false);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> handleSignOut() async {
    setState(() {
      isLoading = true;
    });
    try {
      await authService.signOut();
      if (mounted) {
        _showSnackBar('Đăng xuất thành công', true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      _showSnackBar('Lỗi khi đăng xuất: $e', false);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: authService.currentUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Lỗi khi tải thông tin người dùng'));
        }

        final user = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Cài đặt'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Thông tin hồ sơ
              ListTile(
                title: const Text('Email'),
                subtitle: Text(user.email ?? 'Chưa có email'),
              ),
              ListTile(
                title: const Text('Số điện thoại'),
                subtitle: Text(
                  user.phoneNumber.isNotEmpty == true
                      ? user.phoneNumber
                      : 'Chưa có số điện thoại',
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'Họ'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Tên'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed: isLoading ? null : handleUpdateProfile,
                  child:
                      isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Cập nhật hồ sơ',
                            style: TextStyle(fontSize: 16),
                          ),
                ),
              ),
              // Đổi mật khẩu
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
                  obscureText: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed: isLoading ? null : handleChangePassword,
                  child:
                      isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Đổi mật khẩu',
                            style: TextStyle(fontSize: 16),
                          ),
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
                  onChanged: isLoading ? null : handleToggleTwoStep,
                ),
              ),
              // Nút đăng xuất
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed: isLoading ? null : handleSignOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child:
                      isLoading
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
