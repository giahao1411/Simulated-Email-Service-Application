import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _verificationId;

  // Định dạng số điện thoại
  String _formatPhoneNumber(String phoneNumber) {
    if (!phoneNumber.startsWith('+')) {
      if (phoneNumber.startsWith('0')) {
        return '+84${phoneNumber.substring(1)}';
      } else {
        return '+84$phoneNumber';
      }
    }
    return phoneNumber;
  }

  // Gửi OTP
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      final formattedPhoneNumber = _formatPhoneNumber(phoneNumber);
      print('Gửi OTP đến: $formattedPhoneNumber - Bắt đầu quá trình xác minh');

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          print('Xác minh tự động hoàn tất (chỉ trên Android)');
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Lỗi gửi OTP: ${e.code} - ${e.message}');
          print('Chi tiết lỗi: ${e.toString()}');
          String errorMessage;
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'Số điện thoại không hợp lệ';
              break;
            case 'quota-exceeded':
              errorMessage = 'Đã vượt quá hạn mức gửi OTP, thử lại sau';
              break;
            case 'too-many-requests':
              errorMessage = 'Quá nhiều yêu cầu, vui lòng thử lại sau';
              break;
            case 'app-not-authorized':
              errorMessage = 'Ứng dụng chưa được cấp quyền, kiểm tra App Check';
              break;
            default:
              errorMessage = 'Gửi OTP thất bại: ${e.message}';
          }
          onError(errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          print('Mã OTP đã được gửi, verificationId: $verificationId');
          _verificationId = verificationId;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('Hết thời gian tự động lấy mã OTP, verificationId: $verificationId');
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      print('Lỗi gửi OTP: $e');
      onError('Gửi OTP thất bại: $e');
    }
  }

  // Xác minh OTP
  Future<bool> verifyOtp({
    required String otp,
    required String verificationId,
  }) async {
    try {
      print('Xác minh OTP: $otp');
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
      print('Xác minh OTP thành công');
      return true;
    } on FirebaseAuthException catch (e) {
      print('Lỗi xác minh OTP: ${e.message}');
      String errorMessage;
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'Mã OTP không đúng';
          break;
        case 'session-expired':
          errorMessage = 'Phiên xác minh đã hết hạn, vui lòng gửi lại OTP';
          break;
        default:
          errorMessage = 'Xác minh OTP thất bại: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Lỗi xác minh OTP: $e');
      rethrow;
    }
  }

  // Đăng ký với số điện thoại và email/mật khẩu
  Future<UserProfile?> register({
    required String email,
    required String password,
    required String phoneNumber,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    required String verificationId,
    required String otp,
  }) async {
    try {
      print('Bắt đầu đăng ký với email: $email, phone: $phoneNumber');

      // Xác minh OTP trước khi tạo tài khoản
      final otpVerified = await verifyOtp(
        otp: otp,
        verificationId: verificationId,
      );
      if (!otpVerified) {
        throw Exception('Xác minh OTP không thành công');
      }

      // Tạo người dùng với email và mật khẩu
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Hết thời gian chờ khi tạo tài khoản');
            },
          );
      User? user = userCredential.user;

      if (user != null) {
        print('Tài khoản được tạo với UID: ${user.uid}');

        // Định dạng số điện thoại
        String formattedPhoneNumber = _formatPhoneNumber(phoneNumber);

        // Tạo hồ sơ người dùng
        UserProfile userProfile = UserProfile(
          uid: user.uid,
          phoneNumber: formattedPhoneNumber,
          firstName: firstName,
          lastName: lastName,
          dateOfBirth: dateOfBirth,
          photoUrl: '',
          email: email,
          twoStepEnabled: false,
        );

        // Lưu vào Firestore
        try {
          print('Đang lưu hồ sơ vào Firestore...');
          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(userProfile.toMap(), SetOptions(merge: true))
              .timeout(
                const Duration(seconds: 30),
                onTimeout: () {
                  throw Exception(
                    'Hết thời gian chờ khi lưu hồ sơ vào Firestore',
                  );
                },
              );
          print('Lưu hồ sơ vào Firestore thành công');
        } catch (e) {
          print('Lỗi khi lưu hồ sơ vào Firestore: $e');
          throw Exception('Không thể lưu hồ sơ: $e');
        }

        return userProfile;
      }
      print('Không tạo được tài khoản');
      return null;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.message}');
      if (e.code == 'email-already-in-use') {
        throw Exception('Email đã được sử dụng');
      } else if (e.code == 'invalid-email') {
        throw Exception('Email không hợp lệ');
      } else if (e.code == 'weak-password') {
        throw Exception('Mật khẩu quá yếu');
      }
      throw Exception('Đăng ký thất bại: ${e.message}');
    } catch (e) {
      print('Lỗi đăng ký: $e');
      rethrow;
    }
  }

  // Đăng nhập với email và mật khẩu
  Future<UserProfile?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      print('Bắt đầu đăng nhập với email: $email');

      UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Hết thời gian chờ khi đăng nhập');
            },
          );
      User? user = userCredential.user;

      if (user != null) {
        print('Đăng nhập thành công với UID: ${user.uid}');

        // Lấy hồ sơ từ Firestore
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get()
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw Exception('Hết thời gian chờ khi lấy hồ sơ từ Firestore');
              },
            );

        if (doc.exists) {
          print('Lấy hồ sơ từ Firestore thành công');
          return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
        } else {
          print('Không tìm thấy hồ sơ, tạo hồ sơ mặc định');
          return UserProfile(
            uid: user.uid,
            phoneNumber: '',
            firstName: '',
            lastName: '',
            dateOfBirth: null,
            photoUrl: user.photoURL ?? '',
            email: user.email ?? '',
            twoStepEnabled: false,
          );
        }
      }
      print('Không đăng nhập được');
      return null;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.message}');
      if (e.code == 'user-not-found') {
        throw Exception('Không tìm thấy người dùng');
      } else if (e.code == 'wrong-password') {
        throw Exception('Mật khẩu không đúng');
      } else if (e.code == 'invalid-email') {
        throw Exception('Email không hợp lệ');
      }
      throw Exception('Đăng nhập thất bại: ${e.message}');
    } catch (e) {
      print('Lỗi đăng nhập: $e');
      rethrow;
    }
  }

  // Đổi mật khẩu
  Future<void> changePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('Không có người dùng đăng nhập');
      }
      if (newPassword.length < 6) {
        throw Exception('Mật khẩu mới phải có ít nhất 6 ký tự');
      }
      await user.updatePassword(newPassword);
      print('Đổi mật khẩu thành công');
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.message}');
      if (e.code == 'requires-recent-login') {
        throw Exception('Vui lòng đăng nhập lại để đổi mật khẩu');
      }
      throw Exception('Đổi mật khẩu thất bại: ${e.message}');
    } catch (e) {
      print('Lỗi đổi mật khẩu: $e');
      rethrow;
    }
  }

  // Khôi phục mật khẩu bằng OTP
  Future<void> resetPasswordWithOtp({
    required String phoneNumber,
    required String verificationId,
    required String otp,
    required String newPassword,
    required String oldPassword,
  }) async {
    try {
      // Xác minh OTP
      final otpVerified = await verifyOtp(
        otp: otp,
        verificationId: verificationId,
      );
      if (!otpVerified) {
        throw Exception('Xác minh OTP không thành công');
      }

      // Kiểm tra định dạng số điện thoại
      final formattedPhoneNumber = _formatPhoneNumber(phoneNumber);

      // Tìm tài khoản người dùng theo số điện thoại
      final QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: formattedPhoneNumber)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception(
          'Không tìm thấy tài khoản liên kết với số điện thoại này',
        );
      }

      final userDoc = userQuery.docs.first;
      final userData = userDoc.data() as Map<String, dynamic>;
      final String userEmail = (userData['email'] ?? '') as String;

      if (userEmail.isEmpty) {
        throw Exception('Không tìm thấy email liên kết với số điện thoại này');
      }

      // Đăng nhập với email/mật khẩu cũ
      await _auth.signInWithEmailAndPassword(
        email: userEmail,
        password: oldPassword,
      );

      // Đổi mật khẩu
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Không có người dùng đăng nhập');
      }
      if (newPassword.length < 6) {
        throw Exception('Mật khẩu mới phải có ít nhất 6 ký tự');
      }
      await user.updatePassword(newPassword);
      print('Đổi mật khẩu thành công');

      // Đăng xuất sau khi đổi mật khẩu
      await _auth.signOut();
      print('Đăng xuất sau khi khôi phục mật khẩu');
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.message}');
      if (e.code == 'wrong-password') {
        throw Exception('Mật khẩu cũ không đúng');
      } else if (e.code == 'user-not-found') {
        throw Exception('Không tìm thấy người dùng với email này');
      }
      throw Exception('Khôi phục mật khẩu thất bại: ${e.message}');
    } catch (e) {
      print('Lỗi khôi phục mật khẩu: $e');
      rethrow;
    }
  }

  // Bật/tắt xác minh hai bước
  Future<void> enableTwoStepVerification(bool enable) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('Không có người dùng đăng nhập');
      }
      await _firestore.collection('users').doc(user.uid).set({
        'twoStepEnabled': enable,
      }, SetOptions(merge: true));
      print('Cập nhật xác minh hai bước thành công: $enable');
    } catch (e) {
      print('Lỗi cập nhật xác minh hai bước: $e');
      rethrow;
    }
  }

  // Lấy người dùng hiện tại
  Future<UserProfile?> get currentUser async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        print('Lấy thông tin người dùng hiện tại: ${user.uid}');
        // Lấy hồ sơ từ Firestore
        final DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get()
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw Exception('Hết thời gian chờ khi lấy hồ sơ từ Firestore');
              },
            );

        if (doc.exists) {
          print('Lấy hồ sơ từ Firestore thành công');
          return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
        } else {
          print('Không tìm thấy hồ sơ, tạo hồ sơ mặc định');
          return UserProfile(
            uid: user.uid,
            phoneNumber: '',
            firstName: '',
            lastName: '',
            dateOfBirth: null,
            photoUrl: user.photoURL ?? '',
            email: user.email ?? '',
            twoStepEnabled: false,
          );
        }
      }
      return null;
    } catch (e) {
      print('Lỗi lấy thông tin người dùng hiện tại: $e');
      return null;
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('Đăng xuất thành công');
    } catch (e) {
      print('Lỗi đăng xuất: $e');
      rethrow;
    }
  }
}