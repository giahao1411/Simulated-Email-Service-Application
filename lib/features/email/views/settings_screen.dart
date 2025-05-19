import 'package:email_application/features/email/controllers/auth_service.dart';
import 'package:email_application/features/email/controllers/profile_service.dart';
import 'package:email_application/features/email/controllers/settings_controller.dart';
import 'package:email_application/features/email/models/user_profile.dart';
import 'package:email_application/features/email/providers/theme_manage.dart';
import 'package:email_application/features/email/views/widgets/profile_avatar.dart';
import 'package:email_application/features/email/views/widgets/profile_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      dateOfBirthController: TextEditingController(),
    );
    _controller.loadProfile().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.firstNameController.dispose();
    _controller.lastNameController.dispose();
    _controller.passwordController.dispose();
    _controller.dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final theme = Theme.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _controller.dateOfBirthController.text.isNotEmpty
              ? DateTime.parse(_controller.dateOfBirthController.text)
              : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: Colors.red[700],
              onPrimary: Colors.white,
              surface: theme.scaffoldBackgroundColor,
              onSurface:
                  theme.brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.red[700]),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: theme.scaffoldBackgroundColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _controller.dateOfBirthController.text =
            picked.toIso8601String().split('T')[0];
      });
    }
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

        final user = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Cài đặt'),
            foregroundColor: Colors.white,
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
                      onPickImage: () async {
                        try {
                          await _controller.pickImage(context);
                        } catch (e) {
                          // Xử lý lỗi nếu cần
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              ProfileField(
                controller: _controller,
                user: user,
                onDateSelected: () => _selectDate(context),
              ),
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
              Consumer<ThemeManage>(
                builder: (context, themeProvider, child) {
                  return ListTile(
                    title: const Text('Chế độ tối'),
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleDarkMode(value);
                      },
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('Trả lời tự động'),
                trailing: Switch(
                  value: _controller.isAutoReply,
                  onChanged: (value) {
                    setState(() {
                      _controller.isAutoReply = value;
                    });
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
