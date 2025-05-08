import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

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
    String? displayName,
  }) async {
    try {
      print('Bắt đầu đăng ký với email: $email, phone: $phoneNumber');

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
          displayName: displayName ?? '',
          photoUrl: '',
          email: email,
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
            displayName: user.displayName ?? '',
            photoUrl: user.photoURL ?? '',
            email: user.email ?? '',
          );
        }
      }
      print('Không đăng nhập được');
      return null;
    } catch (e) {
      print('Lỗi đăng nhập: $e');
      rethrow;
    }
  }

  // Đổi mật khẩu
  Future<void> changePassword(String newPassword) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
      print('Đổi mật khẩu thành công');
    } else {
      throw Exception('Không có người dùng đăng nhập');
    }
  }

  // Khôi phục mật khẩu
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Gửi email khôi phục mật khẩu thành công');
    } catch (e) {
      print('Lỗi khôi phục mật khẩu: $e');
      rethrow;
    }
  }

  // Bật/tắt xác minh hai bước
  Future<void> enableTwoStepVerification(bool enable) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'twoStepEnabled': enable,
      }, SetOptions(merge: true));
      print('Cập nhật xác minh hai bước thành công: $enable');
    } else {
      throw Exception('Không có người dùng đăng nhập');
    }
  }

  // Lấy người dùng hiện tại
  UserProfile? get currentUser {
    User? user = _auth.currentUser;
    if (user != null) {
      print('Lấy thông tin người dùng hiện tại: ${user.uid}');
      return UserProfile(
        uid: user.uid,
        phoneNumber: '',
        displayName: user.displayName ?? '',
        photoUrl: user.photoURL ?? '',
        email: user.email ?? '',
      );
    }
    return null;
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
    print('Đăng xuất thành công');
  }
}
