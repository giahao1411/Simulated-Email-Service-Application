import 'package:email_application/features/email/controllers/auth_service.dart';
import 'package:email_application/features/email/views/screens/new_password_screen.dart';
import 'package:email_application/features/email/views/screens/otp_verification_screen.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController phoneController = TextEditingController();
  final AuthService authService = AuthService();
  String? errorMessage;
  bool isLoading = false;

  Future<void> handlePasswordReset() async {
    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    try {
      final phone = phoneController.text.trim();
      if (phone.isEmpty) {
        setState(() {
          errorMessage = 'Vui lòng nhập số điện thoại để khôi phục mật khẩu';
          isLoading = false;
        });
        _showSnackBar(errorMessage!, false);
        return;
      }

      // Kiểm tra định dạng số điện thoại
      final phonePattern = RegExp(r'^(?:\+84|0)\d{9}$');
      if (!phonePattern.hasMatch(phone)) {
        setState(() {
          errorMessage =
              '''Số điện thoại không hợp lệ. Vui lòng nhập định dạng +84 hoặc 0xxxxxxxxx''';
          isLoading = false;
        });
        _showSnackBar(errorMessage!, false);
        return;
      }

      // Gửi OTP
      await authService.sendOtp(
        phoneNumber: phone,
        onCodeSent: (verificationId) {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder:
                  (context) => OtpVerificationScreen(
                    phoneNumber: phone,
                    verificationId: verificationId,
                    onOtpVerified: (otp, verificationId) async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder:
                              (context) => NewPasswordScreen(
                                phoneNumber: phone,
                                verificationId: verificationId,
                                otp: otp,
                              ),
                        ),
                      );
                    },
                  ),
            ),
          );
        },
        onError: (error) {
          setState(() {
            errorMessage = error;
            isLoading = false;
          });
          _showSnackBar(error, false);
        },
      );
    } on Exception catch (e) {
      setState(() {
        errorMessage = 'Khôi phục mật khẩu thất bại: $e';
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        title: const Text('Khôi phục mật khẩu'),
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
                'Nhập số điện thoại của bạn',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                '''Chúng tôi sẽ gửi một mã OTP để xác minh và cho phép bạn đặt lại mật khẩu.''',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Số điện thoại',
                  hintText: 'Nhập số điện thoại đã đăng ký',
                  prefixIcon: Icon(Icons.phone, color: iconColor),
                  labelStyle: TextStyle(color: labelTextColor),
                  hintStyle: TextStyle(color: hintTextColor),
                  errorText: errorMessage,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : handlePasswordReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child:
                      isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Gửi mã OTP',
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
