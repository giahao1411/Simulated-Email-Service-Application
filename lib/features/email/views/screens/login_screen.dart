import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/features/email/controllers/auth_service.dart';
import 'package:email_application/features/email/models/user_profile.dart';
import 'package:email_application/features/email/providers/theme_manage.dart';
import 'package:email_application/features/email/providers/two_step_manage.dart';
import 'package:email_application/features/email/views/screens/forgot_password_screen.dart';
import 'package:email_application/features/email/views/screens/gmail_screen.dart';
import 'package:email_application/features/email/views/screens/otp_verification_screen.dart';
import 'package:email_application/features/email/views/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();
  String? errorMessage;
  bool isLoading = false;
  UserProfile? userProfile;
  bool _obscurePassword = true;

  Future<void> handleLogin() async {
    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        setState(() {
          errorMessage = 'Vui lòng nhập email và mật khẩu';
          isLoading = false;
        });
        _showSnackBar(errorMessage!, false);
        return;
      }

      AppFunctions.debugPrint('Bắt đầu đăng nhập với email: $email');
      userProfile = await authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (userProfile == null) {
        setState(() {
          errorMessage =
              'Không thể đăng nhập: Thông tin người dùng không tồn tại';
          isLoading = false;
        });
        _showSnackBar(errorMessage!, false);
        return;
      }

      AppFunctions.debugPrint(
        'Đăng nhập bước 1 thành công với UID: ${userProfile!.uid}',
      );

      if (!mounted) return;
      final twoStepProvider = Provider.of<TwoStepManage>(
        context,
        listen: false,
      );
      if (twoStepProvider.isTwoStepEnabled) {
        AppFunctions.debugPrint(
          'Xác minh hai bước được bật, kiểm tra số điện thoại...',
        );
        if (userProfile!.phoneNumber.isEmpty) {
          setState(() {
            errorMessage = 'Tài khoản không có số điện thoại để gửi OTP';
            isLoading = false;
          });
          _showSnackBar(errorMessage!, false);
          return;
        }

        AppFunctions.debugPrint(
          'Gửi OTP đến số điện thoại: ${userProfile!.phoneNumber}',
        );
        await authService.sendOtp(
          phoneNumber: userProfile!.phoneNumber,
          onCodeSent: (verificationId) {
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder:
                      (context) => OtpVerificationScreen(
                        phoneNumber: userProfile!.phoneNumber,
                        verificationId: verificationId,
                        onOtpVerified: (otp, verificationId) async {
                          try {
                            // Xác minh OTP
                            AppFunctions.debugPrint('Xác minh OTP: $otp');
                            final isVerified = await authService.verifyOtp(
                              otp: otp,
                              verificationId: verificationId,
                            );
                            if (isVerified) {
                              _showSnackBarAndNavigate(
                                'Đăng nhập thành công!',
                                true,
                              );
                            }
                          } on Exception catch (e) {
                            _showSnackBar('Xác minh OTP thất bại: $e', false);
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                      ),
                ),
              );
            }
          },
          onError: (error) {
            setState(() {
              errorMessage = error;
              isLoading = false;
            });
            _showSnackBar(error, false);
          },
        );
      } else {
        AppFunctions.debugPrint(
          'Xác minh hai bước không được bật, đăng nhập bình thường...',
        );
        _showSnackBarAndNavigate('Đăng nhập thành công!', true);
      }
    } on Exception catch (e) {
      setState(() {
        errorMessage = 'Đăng nhập thất bại: email hoặc mật khẩu không đúng';
        isLoading = false;
      });
      _showSnackBar(errorMessage!, false);
      AppFunctions.debugPrint('Đăng nhập thất bại: $e');
    } finally {
      final twoStepProvider = Provider.of<TwoStepManage>(
        context,
        listen: false,
      );
      if (userProfile == null || !twoStepProvider.isTwoStepEnabled) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showSnackBarAndNavigate(String message, bool isSuccess) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
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
        )
        .closed
        .then((_) {
          if (isSuccess && mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(
                builder: (context) => const GmailScreen(),
              ),
            );
          }
        });
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
    final labelStyle = Theme.of(context).inputDecorationTheme.labelStyle;
    final iconColor = labelStyle?.color ?? Colors.black54;
    final themeProvider = Provider.of<ThemeManage>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final labelTextColor = isDarkMode ? Colors.white70 : Colors.grey[600];
    final hintTextColor = isDarkMode ? Colors.white70 : Colors.grey[600];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 48),
                child: Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Gmail_icon_%282020%29.svg/1280px-Gmail_icon_%282020%29.svg.png',
                  width: 80,
                  height: 80,
                ),
              ),
              Text(
                'Đăng nhập',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Nhập email của bạn',
                  prefixIcon: Icon(Icons.email, color: iconColor),
                  labelStyle: TextStyle(color: labelTextColor),
                  hintStyle: TextStyle(color: hintTextColor),
                  errorText: errorMessage,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  hintText: 'Nhập mật khẩu của bạn',
                  prefixIcon: Icon(Icons.lock, color: iconColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: iconColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  labelStyle: TextStyle(color: labelTextColor),
                  hintStyle: TextStyle(color: hintTextColor),
                  errorText: errorMessage,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                obscureText: _obscurePassword,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child:
                      isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Đăng nhập',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Quên mật khẩu?',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Chưa có tài khoản? Đăng ký',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
