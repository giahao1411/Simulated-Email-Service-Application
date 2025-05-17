import 'package:email_application/features/email/controllers/auth_service.dart';
import 'package:email_application/features/email/views/login_screen.dart';
import 'package:email_application/features/email/views/otp_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  DateTime? selectedDate;
  final AuthService authService = AuthService();
  String? errorMessage;
  bool isLoading = false;

  Future<void> handleRegister() async {
    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();
      final phone = phoneController.text.trim();
      final firstName = firstNameController.text.trim();
      final lastName = lastNameController.text.trim();

      if (email.isEmpty ||
          password.isEmpty ||
          confirmPassword.isEmpty ||
          phone.isEmpty ||
          firstName.isEmpty ||
          lastName.isEmpty) {
        setState(() {
          errorMessage = 'Vui lòng điền đầy đủ các trường';
          isLoading = false;
        });
        _showSnackBar(errorMessage!, false);
        return;
      }

      if (password != confirmPassword) {
        setState(() {
          errorMessage = 'Mật khẩu và xác nhận mật khẩu không khớp';
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
            MaterialPageRoute(
              builder:
                  (context) => OtpVerificationScreen(
                    phoneNumber: phone,
                    verificationId: verificationId,
                    onOtpVerified: (otp, verificationId) async {
                      try {
                        await authService.register(
                          email: email,
                          password: password,
                          phoneNumber: phone,
                          firstName: firstName,
                          lastName: lastName,
                          dateOfBirth: selectedDate,
                          verificationId: verificationId,
                          otp: otp,
                        );
                        if (mounted) {
                          _showSnackBar(
                            'Đăng ký thành công! Vui lòng đăng nhập',
                            true,
                          );
                          await Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        }
                      } on Exception catch (e) {
                        _showSnackBar('Đăng ký thất bại: $e', false);
                      }
                    },
                  ),
            ),
          );
          setState(() {
            isLoading = false;
          });
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
        errorMessage = 'Đăng ký thất bại: $e';
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
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> selectDate(BuildContext context) async {
    final theme = Theme.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
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
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).inputDecorationTheme.labelStyle;
    final iconColor = labelStyle?.color ?? Colors.black54;
    final labelTextColor =
        Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.grey[400];
    final hintTextColor =
        Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.grey[400];

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
                'Đăng ký',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: firstNameController,
                      decoration: InputDecoration(
                        labelText: 'Họ',
                        hintText: 'Nhập họ của bạn',
                        prefixIcon: Icon(Icons.person, color: iconColor),
                        labelStyle: TextStyle(color: labelTextColor),
                        hintStyle: TextStyle(color: hintTextColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: lastNameController,
                      decoration: InputDecoration(
                        labelText: 'Tên',
                        hintText: 'Nhập tên của bạn',
                        prefixIcon: Icon(Icons.person, color: iconColor),
                        labelStyle: TextStyle(color: labelTextColor),
                        hintStyle: TextStyle(color: hintTextColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => selectDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText:
                          selectedDate == null
                              ? 'Chọn ngày sinh'
                              : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                      prefixIcon: Icon(Icons.calendar_today, color: iconColor),
                      labelStyle: TextStyle(color: labelTextColor),
                      hintStyle: TextStyle(color: hintTextColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Nhập email của bạn',
                  prefixIcon: Icon(Icons.email, color: iconColor),
                  labelStyle: TextStyle(color: labelTextColor),
                  hintStyle: TextStyle(color: hintTextColor),
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
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Xác nhận mật khẩu',
                  hintText: 'Xác nhận mật khẩu của bạn',
                  prefixIcon: Icon(Icons.lock, color: iconColor),
                  labelStyle: TextStyle(color: labelTextColor),
                  hintStyle: TextStyle(color: hintTextColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Số điện thoại',
                  hintText: 'Nhập số điện thoại của bạn',
                  prefixIcon: Icon(Icons.phone, color: iconColor),
                  labelStyle: TextStyle(color: labelTextColor),
                  hintStyle: TextStyle(color: hintTextColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child:
                      isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Đăng ký',
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
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Đã có tài khoản? Đăng nhập',
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
