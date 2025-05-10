import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? photoUrl,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('Không có người dùng đăng nhập');
      }
      await _firestore.collection('users').doc(user.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'photoUrl': photoUrl,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Lỗi khi cập nhật hồ sơ: $e');
      rethrow;
    }
  }

  Future<UserProfile?> getProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return null;
      }
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Lỗi khi lấy hồ sơ: $e');
      return null;
    }
  }
}
