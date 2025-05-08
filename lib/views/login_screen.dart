import 'package:flutter/material.dart';
import '../controllers/auth_service.dart';
import 'gmail_screen.dart';
import 'register_screen.dart';

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
        return;
      }

      await authService.signInWithEmail(email: email, password: password);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GmailScreen()),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Đăng nhập thất bại: $e';
        isLoading = false;
      });
    }
  }

  Future<void> handlePasswordReset() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        errorMessage = 'Vui lòng nhập email để đặt lại mật khẩu';
      });
      return;
    }

    try {
      await authService.resetPassword(email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Email đặt lại mật khẩu đã được gửi. Kiểm tra hộp thư.',
          ),
        ),
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Đặt lại mật khẩu thất bại: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng nhập'),
        backgroundColor: Colors.grey[850],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Gmail_icon_%282020%29.svg/1280px-Gmail_icon_%282020%29.svg.png',
                width: 70,
                height: 70,
              ),
            ),
            // Trường email
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Nhập email của bạn',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            // Trường mật khẩu
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                hintText: 'Nhập mật khẩu của bạn',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            // Nút đăng nhập
            ElevatedButton(
              onPressed: isLoading ? null : handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: const Size.fromHeight(50),
              ),
              child:
                  isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Đăng nhập', style: TextStyle(fontSize: 16)),
            ),
            // Quên mật khẩu
            TextButton(
              onPressed: handlePasswordReset,
              child: const Text('Quên mật khẩu?'),
            ),
            // Chuyển sang đăng ký
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ),
                );
              },
              child: const Text('Chưa có tài khoản? Đăng ký'),
            ),
            // Thông báo lỗi
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
