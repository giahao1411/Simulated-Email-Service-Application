import 'package:email_application/features/email/controllers/auth_service.dart';
import 'package:email_application/features/email/views/screens/forgot_password_screen.dart';
import 'package:email_application/features/email/views/screens/gmail_screen.dart';
import 'package:email_application/features/email/views/screens/register_screen.dart';
import 'package:flutter/material.dart';

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

      await authService.signInWithEmail(email: email, password: password);

      if (mounted) {
        _showSnackBar('Đăng nhập thành công!', true);
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GmailScreen()),
        );
      }
    } on Exception catch (e) {
      setState(() {
        errorMessage = 'Đăng nhập thất bại: $e';
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
                    MaterialPageRoute(
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
                    MaterialPageRoute(
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
