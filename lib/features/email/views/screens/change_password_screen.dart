import 'package:email_application/features/email/controllers/auth_service.dart';
import 'package:email_application/features/email/providers/theme_manage.dart';
import 'package:email_application/features/email/views/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({required this.phoneNumber, super.key});

  final String phoneNumber;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isLoadingSendOtp = false;
  bool _isLoadingChangePassword = false;
  bool _otpSent = false;
  String? _verificationId;
  String? _errorMessage;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_newPasswordController.text.isEmpty) {
      _showSnackBar('Vui lòng nhập mật khẩu mới', false);
      return;
    }

    if (_newPasswordController.text.length < 6) {
      _showSnackBar('Mật khẩu phải có ít nhất 6 ký tự', false);
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar('Xác nhận mật khẩu không khớp', false);
      return;
    }

    setState(() {
      _isLoadingSendOtp = true;
      _errorMessage = null;
    });

    try {
      await _authService.sendOtp(
        phoneNumber: widget.phoneNumber,
        onCodeSent: (verificationId) {
          setState(() {
            _verificationId = verificationId;
            _otpSent = true;
            _isLoadingSendOtp = false;
          });
          _showSnackBar('Mã OTP đã được gửi đến ${widget.phoneNumber}', true);
        },
        onError: (error) {
          setState(() {
            _errorMessage = error;
            _isLoadingSendOtp = false;
          });
          _showSnackBar(error, false);
        },
      );
    } on Exception catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi gửi OTP: $e';
        _isLoadingSendOtp = false;
      });
      _showSnackBar(_errorMessage!, false);
    }
  }

  Future<void> _changePassword() async {
    if (_otpController.text.isEmpty || _otpController.text.length != 6) {
      _showSnackBar('Vui lòng nhập mã OTP 6 chữ số', false);
      return;
    }

    if (_verificationId == null) {
      _showSnackBar('Lỗi: Không có mã xác minh', false);
      return;
    }

    setState(() {
      _isLoadingChangePassword = true;
      _errorMessage = null;
    });

    try {
      await _authService.resetPasswordWithOtp(
        phoneNumber: widget.phoneNumber,
        verificationId: _verificationId!,
        otp: _otpController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
      );

      _showSnackBar('Đổi mật khẩu thành công', true);

      // Đợi một chút để user thấy thông báo thành công
      await Future<void>.delayed(const Duration(seconds: 1));

      if (mounted) {
        // Đăng xuất người dùng
        await _authService.signOut();

        // Chuyển hướng đến màn hình đăng nhập
        if (mounted) {
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute<dynamic>(
              builder: (context) => const LoginScreen(),
            ),
          );
        }
      }
    } on Exception catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi đổi mật khẩu: $e';
        _isLoadingChangePassword = false;
      });
      _showSnackBar(_errorMessage!, false);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeManage>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    // Định nghĩa màu sắc theo theme
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final labelTextColor = isDarkMode ? Colors.white70 : Colors.grey[600];
    final hintTextColor = isDarkMode ? Colors.white38 : Colors.grey[400];
    final descriptionTextColor =
        isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final borderColor = isDarkMode ? Colors.grey[600] : Colors.grey[300];
    final focusedBorderColor = theme.colorScheme.primary;
    final iconColor = isDarkMode ? Colors.white70 : Colors.black54;
    final successBackgroundColor =
        isDarkMode ? Colors.green[800] : Colors.green[50];
    final successBorderColor =
        isDarkMode ? Colors.green[600] : Colors.green[300];
    final successTextColor = isDarkMode ? Colors.green[300] : Colors.green[700];
    final errorBackgroundColor = isDarkMode ? Colors.red[800] : Colors.red[50];
    final errorBorderColor = isDarkMode ? Colors.red[600] : Colors.red[300];
    final errorTextColor = isDarkMode ? Colors.red[300] : Colors.red[700];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
        foregroundColor: Colors.white,
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đổi mật khẩu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '''Để bảo mật tài khoản, chúng tôi sẽ gửi mã OTP đến số điện thoại ${widget.phoneNumber} để xác minh danh tính.''',
                style: TextStyle(fontSize: 16, color: descriptionTextColor),
              ),
              const SizedBox(height: 32),

              // Mật khẩu mới
              TextField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Mật khẩu mới',
                  hintText: 'Nhập mật khẩu mới (ít nhất 6 ký tự)',
                  prefixIcon: Icon(Icons.lock_outline, color: iconColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: iconColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                  labelStyle: TextStyle(color: labelTextColor),
                  hintStyle: TextStyle(color: hintTextColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: focusedBorderColor, width: 2),
                  ),
                ),
                enabled: !_otpSent,
              ),
              const SizedBox(height: 16),

              // Xác nhận mật khẩu
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: 'Xác nhận mật khẩu mới',
                  hintText: 'Nhập lại mật khẩu mới',
                  prefixIcon: Icon(Icons.lock_outline, color: iconColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: iconColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  labelStyle: TextStyle(color: labelTextColor),
                  hintStyle: TextStyle(color: hintTextColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: focusedBorderColor, width: 2),
                  ),
                ),
                enabled: !_otpSent,
              ),
              const SizedBox(height: 24),

              // Nút gửi OTP
              if (!_otpSent)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoadingSendOtp ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child:
                        _isLoadingSendOtp
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Gửi mã OTP',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                  ),
                ),

              // Phần nhập OTP (hiện khi đã gửi OTP)
              if (_otpSent) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: successBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: successBorderColor!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: successTextColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mã OTP đã được gửi đến ${widget.phoneNumber}',
                          style: TextStyle(color: successTextColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Mã OTP',
                    hintText: 'Nhập mã OTP 6 chữ số',
                    prefixIcon: Icon(Icons.vpn_key, color: iconColor),
                    labelStyle: TextStyle(color: labelTextColor),
                    hintStyle: TextStyle(color: hintTextColor),
                    counterStyle: TextStyle(color: labelTextColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: focusedBorderColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isLoadingChangePassword ? null : _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child:
                        _isLoadingChangePassword
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Đổi mật khẩu',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 16),

                // Nút gửi lại OTP
                Center(
                  child: TextButton(
                    onPressed:
                        _isLoadingSendOtp
                            ? null
                            : () {
                              setState(() {
                                _otpSent = false;
                                _verificationId = null;
                                _otpController.clear();
                              });
                            },
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                    ),
                    child: const Text(
                      'Gửi lại mã OTP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],

              // Hiển thị lỗi nếu có
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: errorBackgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: errorBorderColor!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: errorTextColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: errorTextColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
