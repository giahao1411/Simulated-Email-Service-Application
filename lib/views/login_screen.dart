import 'package:flutter/material.dart';
import '../controllers/auth_service.dart';
import 'gmail_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final AuthService authService = AuthService();
  String? verificationId;
  String? errorMessage;

  Future<void> handleSendOtp() async {
    try {
      await authService.sendOtp(phoneController.text, (String vId) {
        setState(() {
          verificationId = vId;
          errorMessage = null;
        });
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  Future<void> handleVerifyOtp() async {
    try {
      await authService.signInWithPhone(
        phoneController.text,
        otpController.text,
        verificationId!,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GmailScreen()),
      );
    } catch (e) {
      setState(() {
        errorMessage = "Mã OTP không hợp lệ";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Số điện thoại"),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: handleSendOtp,
              child: const Text("Gửi mã OTP"),
            ),
            if (verificationId != null) ...[
              TextField(
                controller: otpController,
                decoration: const InputDecoration(labelText: "Mã OTP"),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: handleVerifyOtp,
                child: const Text("Xác minh OTP"),
              ),
            ],
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
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
