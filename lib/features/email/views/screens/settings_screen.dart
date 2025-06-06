import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/features/email/controllers/auth_service.dart';
import 'package:email_application/features/email/controllers/profile_service.dart';
import 'package:email_application/features/email/controllers/settings_controller.dart';
import 'package:email_application/features/email/models/user_profile.dart';
import 'package:email_application/features/email/providers/theme_manage.dart';
import 'package:email_application/features/email/providers/two_step_manage.dart';
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
      dateOfBirthController: TextEditingController(),
    );
    _controller.loadProfile().then((_) {
      if (mounted) {
        setState(() {
          final _ = Provider.of<TwoStepManage>(context, listen: false)
            ..setTwoStepEnabled(_controller.isTwoStepEnabled);
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.firstNameController.dispose();
    _controller.lastNameController.dispose();
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

  Future<void> _handleTwoStepToggle(BuildContext context, bool value) async {
    final twoStepProvider = Provider.of<TwoStepManage>(context, listen: false);
    try {
      await _controller.toggleTwoStep(context, value);
      twoStepProvider.toggleTwoStep(value);
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
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
                        } on Exception catch (e) {
                          AppFunctions.debugPrint(
                            'Lỗi khi chọn ảnh đại diện: $e',
                          );
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

              // Phân cách giữa phần profile và phần bảo mật
              const Divider(height: 32),

              // Phần bảo mật
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Bảo mật',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              // Nút đổi mật khẩu (không còn TextField nhập mật khẩu)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: OutlinedButton.icon(
                  onPressed:
                      _controller.isLoading
                          ? null
                          : () => _controller.changePassword(context),
                  icon: const Icon(Icons.lock_outline),
                  label: const Text(
                    'Đổi mật khẩu',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              // Xác minh hai bước
              Consumer<TwoStepManage>(
                builder: (context, twoStepProvider, child) {
                  return ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('Xác minh hai bước'),
                    trailing: Switch(
                      value: twoStepProvider.isTwoStepEnabled,
                      onChanged:
                          (value) => _handleTwoStepToggle(context, value),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Phần cài đặt khác
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Cài đặt ứng dụng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              Consumer<ThemeManage>(
                builder: (context, themeProvider, child) {
                  return ListTile(
                    leading: const Icon(Icons.dark_mode),
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
                leading: const Icon(Icons.auto_awesome),
                title: const Text('Trả lời tự động'),
                trailing: Switch(
                  value: _controller.isAutoReply,
                  onChanged: (value) {
                    setState(() {
                      _controller.isAutoReply = value;
                    });
                    _controller
                        .toggleAutoReply(context, value)
                        .then((_) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Cập nhật trả lời tự động thành công',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        })
                        .catchError((Object e) {
                          if (mounted) {
                            setState(() {
                              _controller.isAutoReply = !value;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Lỗi khi bật trả lời tự động: $e',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        });
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Nút đăng xuất
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
                            style: TextStyle(fontSize: 16, color: Colors.white),
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
