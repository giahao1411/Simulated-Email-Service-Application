import 'package:email_application/features/email/controllers/auth_service.dart';
import 'package:email_application/features/email/views/screens/login_screen.dart';
import 'package:flutter/material.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({
    required this.phoneNumber,
    required this.verificationId,
    required this.otp,
    super.key,
  });

  final String phoneNumber;
  final String verificationId;
  final String otp;

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final AuthService authService = AuthService();
  String? errorMessage;
  bool isLoading = false;

  Future<void> handleSetNewPassword() async {
    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    try {
      final newPassword = newPasswordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();

      if (newPassword.isEmpty || confirmPassword.isEmpty) {
        setState(() {
          errorMessage =
              'Vui lòng nhập đầy đủ mật khẩu mới và xác nhận mật khẩu';
          isLoading = false;
        });
        _showSnackBar(errorMessage!, false);
        return;
      }

      if (newPassword != confirmPassword) {
        setState(() {
          errorMessage = 'Mật khẩu mới và xác nhận mật khẩu không khớp';
          isLoading = false;
        });
        _showSnackBar(errorMessage!, false);
        return;
      }

      if (newPassword.length < 6) {
        setState(() {
          errorMessage = 'Mật khẩu mới phải có ít nhất 6 ký tự';
          isLoading = false;
        });
        _showSnackBar(errorMessage!, false);
        return;
      }

      await authService.resetPasswordWithOtp(
        phoneNumber: widget.phoneNumber,
        verificationId: widget.verificationId,
        otp: widget.otp,
        newPassword: newPassword,
      );

      _showSnackBar(
        'Mật khẩu đã được cập nhật thành công. Vui lòng đăng nhập lại.',
        true,
      );
      if (mounted) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(builder: (context) => const LoginScreen()),
        );
      }
    } on Exception catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
      _showSnackBar(errorMessage!, false);
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
        duration: const Duration(seconds: 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).inputDecorationTheme.labelStyle;
    final iconColor = labelStyle?.color ?? Colors.black54;
    final labelTextColor =
        Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.grey[400]!;
    final hintTextColor =
        Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[400]!
            : Colors.grey[400]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt mật khẩu mới'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Xác minh hoàn tất',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Vui lòng nhập mật khẩu mới để cập nhật tài khoản của bạn.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu mới',
                  hintText: 'Nhập mật khẩu mới',
                  prefixIcon: Icon(Icons.lock, color: iconColor),
                  labelStyle: TextStyle(color: labelTextColor),
                  hintStyle: TextStyle(color: hintTextColor),
                  errorText: errorMessage,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Xác nhận mật khẩu',
                  hintText: 'Xác nhận mật khẩu mới',
                  prefixIcon: Icon(Icons.lock, color: iconColor),
                  labelStyle: TextStyle(color: labelTextColor),
                  hintStyle: TextStyle(color: hintTextColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : handleSetNewPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child:
                      isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Cập nhật mật khẩu',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
