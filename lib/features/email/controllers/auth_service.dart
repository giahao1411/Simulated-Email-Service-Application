import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/features/email/models/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String) onCodeSent,
    required void Function(String) onError,
    String? email,
    String? password,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
  }) async {
    try {
      final formattedPhoneNumber = _formatPhoneNumber(phoneNumber);
      AppFunctions.debugPrint(
        'Gửi OTP đến: $formattedPhoneNumber - Bắt đầu quá trình xác minh',
      );

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          AppFunctions.debugPrint(
            'Xác minh tự động hoàn tất (chỉ trên Android)',
          );
          if (email != null && password != null) {
            try {
              await _auth.signInWithCredential(credential);
              await register(
                email: email,
                password: password,
                phoneNumber: phoneNumber,
                firstName: firstName,
                lastName: lastName,
                dateOfBirth: dateOfBirth,
                verificationId: credential.verificationId ?? '',
                otp: credential.smsCode ?? '',
              );
              AppFunctions.debugPrint('Đăng ký tự động thành công');
            } on Exception catch (e) {
              AppFunctions.debugPrint('Lỗi đăng ký tự động: $e');
              onError('Đăng ký tự động thất bại: $e');
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          AppFunctions.debugPrint('Lỗi gửi OTP: ${e.code} - ${e.message}');
          AppFunctions.debugPrint('Chi tiết lỗi: $e');
          String errorMessage;
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'Số điện thoại không hợp lệ';
            case 'quota-exceeded':
              errorMessage = 'Đã vượt quá hạn mức gửi OTP, thử lại sau';
            case 'too-many-requests':
              errorMessage = 'Quá nhiều yêu cầu, vui lòng thử lại sau';
            case 'app-not-authorized':
              errorMessage = 'Ứng dụng chưa được cấp quyền, kiểm tra App Check';
            default:
              errorMessage = 'Gửi OTP thất bại: ${e.message}';
          }
          onError(errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          AppFunctions.debugPrint(
            'Mã OTP đã được gửi, verificationId: $verificationId',
          );
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          AppFunctions.debugPrint(
            'Hết thời gian tự động lấy mã OTP, verificationId: $verificationId',
          );
        },
        timeout: const Duration(seconds: 30),
      );
    } on Exception catch (e) {
      AppFunctions.debugPrint('Lỗi gửi OTP: $e');
      onError('Gửi OTP thất bại: $e');
    }
  }

  // Xác minh OTP
  Future<bool> verifyOtp({
    required String otp,
    required String verificationId,
  }) async {
    try {
      AppFunctions.debugPrint('Xác minh OTP: $otp');
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
      AppFunctions.debugPrint('Xác minh OTP thành công');
      return true;
    } on FirebaseAuthException catch (e) {
      AppFunctions.debugPrint('Lỗi xác minh OTP: ${e.message}');
      String errorMessage;
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'Mã OTP không đúng';
        case 'session-expired':
          errorMessage = 'Phiên xác minh đã hết hạn, vui lòng gửi lại OTP';
        default:
          errorMessage = 'Xác minh OTP thất bại: ${e.message}';
      }
      throw Exception(errorMessage);
    } on Exception catch (e) {
      AppFunctions.debugPrint('Lỗi xác minh OTP: $e');
      rethrow;
    }
  }

  // Đăng ký với số điện thoại và email/mật khẩu
  Future<UserProfile?> register({
    required String email,
    required String password,
    required String phoneNumber,
    required String verificationId,
    required String otp,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
  }) async {
    try {
      AppFunctions.debugPrint(
        'Bắt đầu đăng ký với email: $email, phone: $phoneNumber',
      );

      // Tạo tài khoản email/mật khẩu
      final userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw Exception('Hết thời gian chờ khi tạo tài khoản');
            },
          );
      final user = userCredential.user;

      if (user != null) {
        AppFunctions.debugPrint('Tài khoản được tạo với UID: ${user.uid}');

        // Liên kết số điện thoại
        final credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: otp,
        );
        await user.linkWithCredential(credential);
        AppFunctions.debugPrint('Liên kết số điện thoại thành công');

        final formattedPhoneNumber = _formatPhoneNumber(phoneNumber);

        // Tạo hồ sơ người dùng
        final userProfile = UserProfile(
          uid: user.uid,
          phoneNumber: formattedPhoneNumber,
          firstName: firstName,
          lastName: lastName,
          dateOfBirth: dateOfBirth,
          photoUrl: '',
          email: email,
          twoStepEnabled: false,
        );

        try {
          AppFunctions.debugPrint('Đang lưu hồ sơ vào Firestore...');
          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(userProfile.toMap(), SetOptions(merge: true))
              .timeout(
                const Duration(seconds: 15),
                onTimeout: () {
                  throw Exception(
                    'Hết thời gian chờ khi lưu hồ sơ vào Firestore',
                  );
                },
              );
          AppFunctions.debugPrint('Lưu hồ sơ vào Firestore thành công');
        } on Exception catch (e) {
          AppFunctions.debugPrint('Lỗi khi lưu hồ sơ vào Firestore: $e');
          throw Exception('Không thể lưu hồ sơ: $e');
        }

        return userProfile;
      }
      AppFunctions.debugPrint('Không tạo được tài khoản');
      return null;
    } on FirebaseAuthException catch (e) {
      AppFunctions.debugPrint('FirebaseAuthException: ${e.message}');
      if (e.code == 'email-already-in-use') {
        throw Exception('Email đã được sử dụng');
      } else if (e.code == 'invalid-email') {
        throw Exception('Email không hợp lệ');
      } else if (e.code == 'weak-password') {
        throw Exception('Mật khẩu quá yếu');
      }
      throw Exception('Đăng ký thất bại: ${e.message}');
    } on Exception catch (e) {
      AppFunctions.debugPrint('Lỗi đăng ký: $e');
      rethrow;
    }
  }

  // Đăng nhập với email và mật khẩu
  Future<UserProfile?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      AppFunctions.debugPrint('Bắt đầu đăng nhập với email: $email');

      final userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw Exception('Hết thời gian chờ khi đăng nhập');
            },
          );
      final user = userCredential.user;

      if (user != null) {
        AppFunctions.debugPrint('Đăng nhập thành công với UID: ${user.uid}');

        // Lấy hồ sơ từ Firestore
        final DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get()
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                throw Exception('Hết thời gian chờ khi lấy hồ sơ từ Firestore');
              },
            );

        if (doc.exists) {
          AppFunctions.debugPrint('Lấy hồ sơ từ Firestore thành công');
          return UserProfile.fromMap(doc.data()! as Map<String, dynamic>);
        } else {
          AppFunctions.debugPrint('Không tìm thấy hồ sơ, tạo hồ sơ mặc định');
          return UserProfile(
            uid: user.uid,
            phoneNumber: '',
            firstName: '',
            lastName: '',
            photoUrl: user.photoURL ?? '',
            email: user.email ?? '',
            twoStepEnabled: false,
          );
        }
      }
      AppFunctions.debugPrint('Không đăng nhập được');
      return null;
    } on FirebaseAuthException catch (e) {
      AppFunctions.debugPrint('FirebaseAuthException: ${e.message}');
      if (e.code == 'user-not-found') {
        throw Exception('Không tìm thấy người dùng');
      } else if (e.code == 'wrong-password') {
        throw Exception('Mật khẩu không đúng');
      } else if (e.code == 'invalid-email') {
        throw Exception('Email không hợp lệ');
      }
      throw Exception('Đăng nhập thất bại: ${e.message}');
    } on Exception catch (e) {
      AppFunctions.debugPrint('Lỗi đăng nhập: $e');
      rethrow;
    }
  }

  // Đổi mật khẩu
  Future<void> changePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Không có người dùng đăng nhập');
      }
      if (newPassword.length < 6) {
        throw Exception('Mật khẩu mới phải có ít nhất 6 ký tự');
      }
      await user.updatePassword(newPassword);
      AppFunctions.debugPrint('Đổi mật khẩu thành công');
    } on FirebaseAuthException catch (e) {
      AppFunctions.debugPrint('FirebaseAuthException: ${e.message}');
      if (e.code == 'requires-recent-login') {
        throw Exception('Vui lòng đăng nhập lại để đổi mật khẩu');
      }
      throw Exception('Đổi mật khẩu thất bại: ${e.message}');
    } on Exception catch (e) {
      AppFunctions.debugPrint('Lỗi đổi mật khẩu: $e');
      rethrow;
    }
  }

  // Khôi phục mật khẩu bằng OTP
  Future<void> resetPasswordWithOtp({
    required String phoneNumber,
    required String verificationId,
    required String otp,
    required String newPassword,
  }) async {
    try {
      // Xác minh OTP
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final phoneUser = userCredential.user;

      if (phoneUser == null) {
        throw Exception('Xác minh OTP thất bại, không có người dùng');
      }

      AppFunctions.debugPrint(
        'Đăng nhập bằng OTP thành công, UID: ${phoneUser.uid}',
      );

      // Kiểm tra định dạng số điện thoại
      final formattedPhoneNumber = _formatPhoneNumber(phoneNumber);

      // Tìm tài khoản người dùng theo số điện thoại
      final QuerySnapshot userQuery =
          await _firestore
              .collection('users')
              .where('phoneNumber', isEqualTo: formattedPhoneNumber)
              .get();

      if (userQuery.docs.isEmpty) {
        throw Exception(
          'Không tìm thấy tài khoản liên kết với số điện thoại này',
        );
      }

      if (userQuery.docs.length > 1) {
        throw Exception(
          'Có nhiều tài khoản liên kết với số điện thoại này, vui lòng liên hệ hỗ trợ',
        );
      }

      final userDoc = userQuery.docs.first;
      final userData = userDoc.data()! as Map<String, dynamic>;
      final userEmail = userData['email'] as String;
      final userUid = userData['uid'] as String;

      AppFunctions.debugPrint(
        'Tìm thấy tài khoản với email: $userEmail, UID: $userUid',
      );

      if (phoneUser.uid == userUid) {
        // Cập nhật mật khẩu trực tiếp
        try {
          await phoneUser.updatePassword(newPassword);
          AppFunctions.debugPrint('Đã cập nhật mật khẩu thành công');
        } on FirebaseAuthException catch (e) {
          if (e.code == 'requires-recent-login') {
            throw Exception('Yêu cầu đăng nhập lại để đổi mật khẩu');
          } else if (e.code == 'weak-password') {
            throw Exception('Mật khẩu mới quá yếu');
          }
          throw Exception('Cập nhật mật khẩu thất bại: ${e.message}');
        }
      } else {
        // Trường hợp UID không khớp, gửi email đặt lại mật khẩu
        await _auth.sendPasswordResetEmail(email: userEmail);
        AppFunctions.debugPrint(
          'Đã gửi email đặt lại mật khẩu đến: $userEmail',
        );
      }

      // Đăng xuất sau khi hoàn tất
      await _auth.signOut();
      AppFunctions.debugPrint('Đăng xuất sau khi khôi phục mật khẩu');
    } on FirebaseAuthException catch (e) {
      AppFunctions.debugPrint('FirebaseAuthException: ${e.message}');
      if (e.code == 'invalid-verification-code') {
        throw Exception('Mã OTP không đúng');
      } else if (e.code == 'session-expired') {
        throw Exception('Phiên xác minh đã hết hạn, vui lòng gửi lại OTP');
      }
      throw Exception('Khôi phục mật khẩu thất bại: ${e.message}');
    } on Exception catch (e) {
      AppFunctions.debugPrint('Lỗi khôi phục mật khẩu: $e');
      rethrow;
    }
  }

  // Bật/tắt xác minh hai bước
  Future<void> enableTwoStepVerification(bool enable) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Không có người dùng đăng nhập');
      }
      await _firestore.collection('users').doc(user.uid).set({
        'twoStepEnabled': enable,
      }, SetOptions(merge: true));
      AppFunctions.debugPrint('Cập nhật xác minh hai bước thành công: $enable');
    } on Exception catch (e) {
      AppFunctions.debugPrint('Lỗi cập nhật xác minh hai bước: $e');
      rethrow;
    }
  }

  // Lấy người dùng hiện tại
  Future<UserProfile?> get currentUser async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        AppFunctions.debugPrint(
          'Lấy thông tin người dùng hiện tại: ${user.uid}',
        );
        // Lấy hồ sơ từ Firestore
        final DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get()
            .timeout(
              const Duration(seconds: 5), // Giảm từ 10s xuống 5s
              onTimeout: () {
                throw Exception('Hết thời gian chờ khi lấy hồ sơ từ Firestore');
              },
            );

        if (doc.exists) {
          AppFunctions.debugPrint('Lấy hồ sơ từ Firestore thành công');
          return UserProfile.fromMap(doc.data()! as Map<String, dynamic>);
        } else {
          AppFunctions.debugPrint('Không tìm thấy hồ sơ, tạo hồ sơ mặc định');
          return UserProfile(
            uid: user.uid,
            phoneNumber: '',
            firstName: '',
            lastName: '',
            photoUrl: user.photoURL ?? '',
            email: user.email ?? '',
            twoStepEnabled: false,
          );
        }
      }
      return null;
    } on Exception catch (e) {
      AppFunctions.debugPrint('Lỗi lấy thông tin người dùng hiện tại: $e');
      return null;
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      AppFunctions.debugPrint('Đăng xuất thành công');
    } on Exception catch (e) {
      AppFunctions.debugPrint('Lỗi đăng xuất: $e');
      rethrow;
    }
  }
}
