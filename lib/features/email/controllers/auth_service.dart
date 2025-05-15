import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_application/features/email/models/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // Đăng ký với số điện thoại và email/mật khẩu
  Future<UserProfile?> register({
    required String email,
    required String password,
    required String phoneNumber,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
  }) async {
    try {
      print('Bắt đầu đăng ký với email: $email, phone: $phoneNumber');

      // Tạo người dùng với email và mật khẩu
      final userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Hết thời gian chờ khi tạo tài khoản');
            },
          );
      final user = userCredential.user;

      if (user != null) {
        print('Tài khoản được tạo với UID: ${user.uid}');

        // Định dạng số điện thoại
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

      final userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Hết thời gian chờ khi đăng nhập');
            },
          );
      final user = userCredential.user;

      if (user != null) {
        print('Đăng nhập thành công với UID: ${user.uid}');

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
          return UserProfile.fromMap(doc.data()! as Map<String, dynamic>);
        } else {
          print('Không tìm thấy hồ sơ, tạo hồ sơ mặc định');
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
      final user = _auth.currentUser;
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

  // Khôi phục mật khẩu
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Gửi email khôi phục mật khẩu thành công');
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.message}');
      if (e.code == 'invalid-email') {
        throw Exception('Email không hợp lệ');
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
      final user = _auth.currentUser;
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
      final user = _auth.currentUser;
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
          return UserProfile.fromMap(doc.data()! as Map<String, dynamic>);
        } else {
          print('Không tìm thấy hồ sơ, tạo hồ sơ mặc định');
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
