import 'package:flutter/material.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId; // Thêm verificationId làm tham số
  final Function(String, String) onOtpVerified;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId, // Yêu cầu verificationId
    required this.onOtpVerified,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  String? errorMessage;
  bool isLoading = false;

  Future<void> handleVerifyOtp() async {
    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    try {
      final otp = otpController.text.trim();
      if (otp.isEmpty || otp.length != 6) {
        setState(() {
          errorMessage = 'Vui lòng nhập mã OTP 6 chữ số';
          isLoading = false;
        });
        _showSnackBar(errorMessage!, false);
        return;
      }

      // Gọi callback với OTP và verificationId chính xác
      widget.onOtpVerified(otp, widget.verificationId);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Xác minh OTP thất bại: $e';
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
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
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
        Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey[400]!;
    final hintTextColor =
        Theme.of(context).brightness == Brightness.dark ? Colors.grey[400]! : Colors.grey[400]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác minh OTP'),
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
                'Nhập mã OTP',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Chúng tôi đã gửi một mã OTP đến số điện thoại ${widget.phoneNumber}. Vui lòng nhập mã để xác minh.',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: otpController,
                decoration: InputDecoration(
                  labelText: 'Mã OTP',
                  hintText: 'Nhập mã OTP 6 chữ số',
                  prefixIcon: Icon(Icons.vpn_key, color: iconColor),
                  labelStyle: TextStyle(color: labelTextColor),
                  hintStyle: TextStyle(color: hintTextColor),
                  errorText: errorMessage,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : handleVerifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Xác minh OTP',
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