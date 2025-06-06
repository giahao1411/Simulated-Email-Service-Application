import 'package:email_application/features/email/controllers/auth_service.dart';
import 'package:email_application/features/email/controllers/profile_service.dart';
import 'package:email_application/features/email/models/user_profile.dart';
import 'package:email_application/features/email/utils/image_picker_handler.dart';
import 'package:email_application/features/email/views/screens/change_password_screen.dart';
import 'package:email_application/features/email/views/screens/login_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SettingsController {
  SettingsController({
    required this.authService,
    required this.profileService,
    required this.firstNameController,
    required this.lastNameController,
    required this.dateOfBirthController,
  }) {
    _imagePickerHandler = getImagePickerHandler();
  }

  final AuthService authService;
  final ProfileService profileService;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController dateOfBirthController;

  bool isAutoReply = false;
  bool isTwoStepEnabled = false;
  bool isLoading = false;
  UserProfile? userProfile;
  String? _avatarImagePath;
  late final ImagePickerHandlerBase _imagePickerHandler;

  String? get avatarImagePath => _avatarImagePath;

  Future<void> loadProfile() async {
    try {
      final profile = await authService.currentUser;
      if (profile != null) {
        firstNameController.text = profile.firstName ?? '';
        lastNameController.text = profile.lastName ?? '';
        dateOfBirthController.text =
            profile.dateOfBirth?.toIso8601String().split('T')[0] ?? '';
        isTwoStepEnabled = profile.twoStepEnabled ?? false;
        isAutoReply = profile.autoReplyEnabled;
        userProfile = profile;
        _avatarImagePath = profile.photoUrl;
      } else {
        userProfile = null;
        _avatarImagePath = null;
      }
    } on Exception catch (e) {
      _showSnackBar('Lỗi khi tải hồ sơ: $e', false);
    }
  }

  Future<void> pickImage(BuildContext context) async {
    try {
      final imagePath = await _imagePickerHandler.pickImage();
      if (imagePath != null) {
        _avatarImagePath = imagePath;
        await updateAvatar(context, imagePath);
      }
    } on Exception catch (e) {
      _showSnackBar('Lỗi khi chọn ảnh: $e', false, context);
    }
  }

  Future<void> updateAvatar(BuildContext context, String imageData) async {
    isLoading = true;
    try {
      String downloadUrl;
      if (kIsWeb) {
        downloadUrl = await profileService.uploadImageWeb(imageData);
      } else {
        downloadUrl = await profileService.uploadImage(imageData);
      }
      await profileService.updateProfile(photoUrl: downloadUrl);
      _avatarImagePath = downloadUrl;
      _showSnackBar('Cập nhật avatar thành công', true, context);
    } on Exception catch (e) {
      _showSnackBar('Lỗi khi cập nhật avatar: $e', false, context);
    } finally {
      isLoading = false;
    }
  }

  Future<void> updateProfile(BuildContext context) async {
    isLoading = true;
    try {
      final dateOfBirth =
          dateOfBirthController.text.isNotEmpty
              ? DateTime.parse(dateOfBirthController.text)
              : null;
      await profileService.updateProfile(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        dateOfBirth: dateOfBirth,
      );
      _showSnackBar('Cập nhật hồ sơ thành công', true, context);
    } on Exception catch (e) {
      _showSnackBar('Lỗi khi cập nhật hồ sơ: $e', false, context);
    } finally {
      isLoading = false;
    }
  }

  // Phương thức changePassword mới - mở màn hình ChangePasswordScreen
  Future<void> changePassword(BuildContext context) async {
    try {
      if (userProfile?.phoneNumber == null ||
          userProfile!.phoneNumber.isEmpty) {
        _showSnackBar(
          'Không tìm thấy số điện thoại để gửi OTP',
          false,
          context,
        );
        return;
      }

      // Mở màn hình đổi mật khẩu mới
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  ChangePasswordScreen(phoneNumber: userProfile!.phoneNumber),
        ),
      );

      // Nếu đổi mật khẩu thành công
      if (result == true && context.mounted) {
        _showSnackBar('Mật khẩu đã được thay đổi thành công', true, context);
      }
    } on Exception catch (e) {
      _showSnackBar('Lỗi khi mở màn hình đổi mật khẩu: $e', false, context);
    }
  }

  Future<void> toggleTwoStep(BuildContext context, bool value) async {
    isLoading = true;
    try {
      await authService.enableTwoStepVerification(value);
      await profileService.updateProfile(twoStepEnabled: value);
      isTwoStepEnabled = value;
      _showSnackBar('Cập nhật xác minh hai bước thành công', true, context);
    } on Exception catch (e) {
      _showSnackBar('Lỗi khi cập nhật xác minh hai bước: $e', false, context);
    } finally {
      isLoading = false;
    }
  }

  Future<void> toggleAutoReply(BuildContext context, bool value) async {
    try {
      isAutoReply = value;
      await profileService.updateProfile(
        autoReplyEnabled: value,
        autoReplyTime: 5,
      );
    } on Exception catch (e) {
      isAutoReply = !value;
      throw Exception('Lỗi khi cập nhật trả lời tự động: $e');
    }
  }

  Future<void> signOut(BuildContext context) async {
    isLoading = true;
    try {
      await authService.signOut();

      if (Navigator.of(context).mounted) {
        _showSnackBar('Đăng xuất thành công', true, context);
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute<Widget>(builder: (context) => const LoginScreen()),
        );
      }
    } on Exception catch (e) {
      _showSnackBar('Lỗi khi đăng xuất: $e', false, context);
    } finally {
      isLoading = false;
    }
  }

  void _showSnackBar(String message, bool isSuccess, [BuildContext? context]) {
    if (context != null) {
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
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: isSuccess ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
