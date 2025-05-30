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
        'Sending OTP to: $formattedPhoneNumber - Starting verification',
      );

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          AppFunctions.debugPrint(
            'Verification completed automatically (Android only)',
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
              AppFunctions.debugPrint('Automatic registration successful');
            } on Exception catch (e) {
              AppFunctions.debugPrint('Automatic registration error: $e');
              onError('Automatic registration failed: $e');
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          AppFunctions.debugPrint('OTP send error: ${e.code} - ${e.message}');
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
            'OTP code sent, verificationId: $verificationId',
          );
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          AppFunctions.debugPrint(
            'OTP auto-retrieval timeout, verificationId: $verificationId',
          );
        },
      );
    } on Exception catch (e) {
      AppFunctions.debugPrint('Error sending OTP: $e');
      onError('Gửi OTP thất bại: $e');
    }
  }

  Future<bool> verifyOtp({
    required String otp,
    required String verificationId,
  }) async {
    try {
      AppFunctions.debugPrint('Verifying OTP: $otp');
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
      AppFunctions.debugPrint('OTP verification successful');
      return true;
    } on FirebaseAuthException catch (e) {
      AppFunctions.debugPrint('OTP verification error: ${e.message}');
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
    } catch (e) {
      AppFunctions.debugPrint('Error verifying OTP: $e');
      rethrow;
    }
  }

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
        'Starting registration with email: $email, phone: $phoneNumber',
      );

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
        AppFunctions.debugPrint('Account created with UID: ${user.uid}');

        final credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: otp,
        );
        await user.linkWithCredential(credential);
        AppFunctions.debugPrint('Phone number linked successfully');

        final formattedPhone = _formatPhoneNumber(phoneNumber);

        final userProfile = UserProfile(
          uid: user.uid,
          phoneNumber: formattedPhone,
          firstName: firstName,
          lastName: lastName,
          dateOfBirth: dateOfBirth,
          photoUrl: '',
          email: email,
          twoStepEnabled: false,
        );

        try {
          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(userProfile.toMap(), SetOptions(merge: true))
              .timeout(
                const Duration(seconds: 5),
                onTimeout: () {
                  throw Exception('Timeout while saving profile to Firestore');
                },
              );
          AppFunctions.debugPrint('Profile saved to Firestore');
        } catch (e) {
          AppFunctions.debugPrint('Error saving profile to Firestore: $e');
          throw Exception('Failed to save profile: $e');
        }

        return userProfile;
      }
      AppFunctions.debugPrint('Failed to create account');
      return null;
    } on FirebaseAuthException catch (e) {
      AppFunctions.debugPrint('FirebaseAuthException: ${e.message}');
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Email đã được sử dụng');
        case 'invalid-email':
          throw Exception('Email không hợp lệ');
        case 'weak-password':
          throw Exception('Mật khẩu quá yếu');
        default:
          throw Exception('Đăng ký thất bại: ${e.message}');
      }
    } catch (e) {
      AppFunctions.debugPrint('Registration error: $e');
      rethrow;
    }
  }

  Future<UserProfile?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      AppFunctions.debugPrint('Starting sign-in with email: $email');

      final userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw Exception('Timeout while signing in');
            },
          );
      final user = userCredential.user;

      if (user != null) {
        AppFunctions.debugPrint('Sign-in successful with UID: ${user.uid}');

        final DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get()
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                throw Exception(
                  'Timeout while fetching profile from Firestore',
                );
              },
            );

        if (doc.exists) {
          AppFunctions.debugPrint(
            'Profile fetched from Firestore successfully',
          );
          return UserProfile.fromMap(doc.data()! as Map<String, dynamic>);
        } else {
          AppFunctions.debugPrint(
            'Profile not found, creating default profile',
          );
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
      AppFunctions.debugPrint('Sign-in failed');
      return null;
    } on FirebaseAuthException catch (e) {
      AppFunctions.debugPrint('FirebaseAuthException: ${e.message}');
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Không tìm thấy người dùng');
        case 'wrong-password':
          throw Exception('Mật khẩu không đúng');
        case 'invalid-email':
          throw Exception('Email không hợp lệ');
        default:
          throw Exception('Đăng nhập thất bại: ${e.message}');
      }
    } catch (e) {
      AppFunctions.debugPrint('Sign-in error: $e');
      rethrow;
    }
  }

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
      AppFunctions.debugPrint('Password changed successfully');
    } on FirebaseAuthException catch (e) {
      AppFunctions.debugPrint('FirebaseAuthException: ${e.message}');
      switch (e.code) {
        case 'requires-recent-login':
          throw Exception('Vui lòng đăng nhập lại để đổi mật khẩu');
        case 'weak-password':
          throw Exception('Mật khẩu mới quá yếu');
        default:
          throw Exception('Đổi mật khẩu thất bại: ${e.message}');
      }
    } catch (e) {
      AppFunctions.debugPrint('Error changing password: $e');
      rethrow;
    }
  }

  Future<void> resetPasswordWithOtp({
    required String phoneNumber,
    required String verificationId,
    required String otp,
    required String newPassword,
  }) async {
    try {
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
        'Signed in with OTP successfully, UID: ${phoneUser.uid}',
      );

      final formattedPhoneNumber = _formatPhoneNumber(phoneNumber);

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
        'Found account with email: $userEmail, UID: $userUid',
      );

      if (phoneUser.uid == userUid) {
        try {
          await phoneUser.updatePassword(newPassword);
          AppFunctions.debugPrint('Password updated successfully');
        } on FirebaseAuthException catch (e) {
          switch (e.code) {
            case 'requires-recent-login':
              throw Exception('Yêu cầu đăng nhập lại để đổi mật khẩu');
            case 'weak-password':
              throw Exception('Mật khẩu mới quá yếu');
            default:
              throw Exception('Cập nhật mật khẩu thất bại: ${e.message}');
          }
        }
      } else {
        await _auth.sendPasswordResetEmail(email: userEmail);
        AppFunctions.debugPrint('Password reset email sent to: $userEmail');
      }

      await _auth.signOut();
      AppFunctions.debugPrint('Signed out after password reset');
    } on FirebaseAuthException catch (e) {
      AppFunctions.debugPrint('FirebaseAuthException: ${e.message}');
      switch (e.code) {
        case 'invalid-verification-code':
          throw Exception('Mã OTP không đúng');
        case 'session-expired':
          throw Exception('Phiên xác minh đã hết hạn, vui lòng gửi lại OTP');
        default:
          throw Exception('Khôi phục mật khẩu thất bại: ${e.message}');
      }
    } catch (e) {
      AppFunctions.debugPrint('Error resetting password: $e');
      rethrow;
    }
  }

  Future<void> enableTwoStepVerification(bool enable) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Không có người dùng đăng nhập');
      }
      await _firestore.collection('users').doc(user.uid).set({
        'twoStepEnabled': enable,
      }, SetOptions(merge: true));
      AppFunctions.debugPrint('Two-step verification updated: $enable');
    } catch (e) {
      AppFunctions.debugPrint('Error updating two-step verification: $e');
      rethrow;
    }
  }

  Future<UserProfile?> get currentUser async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        AppFunctions.debugPrint('Fetching current user info: ${user.uid}');
        final DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get()
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                throw Exception(
                  'Timeout while fetching profile from Firestore',
                );
              },
            );

        if (doc.exists) {
          AppFunctions.debugPrint(
            'Profile fetched from Firestore successfully',
          );
          return UserProfile.fromMap(doc.data()! as Map<String, dynamic>);
        } else {
          AppFunctions.debugPrint(
            'Profile not found, creating default profile',
          );
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
      AppFunctions.debugPrint('Error fetching current user: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      AppFunctions.debugPrint('Sign-out successful');
    } catch (e) {
      AppFunctions.debugPrint('Error signing out: $e');
      rethrow;
    }
  }
}
