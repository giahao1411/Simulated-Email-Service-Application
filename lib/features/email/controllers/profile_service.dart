import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_application/features/email/models/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseStorage get storage => _storage;

  Future<UserProfile?> getProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.exists ? UserProfile.fromMap(doc.data()!) : null;
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? photoUrl,
    bool? twoStepEnabled,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Người dùng chưa đăng nhập');

    final currentProfile = await getProfile();
    if (currentProfile == null) {
      throw Exception('Không tìm thấy hồ sơ người dùng');
    }

    final updatedProfile = UserProfile(
      uid: currentProfile.uid,
      phoneNumber: currentProfile.phoneNumber,
      firstName: firstName ?? currentProfile.firstName,
      lastName: lastName ?? currentProfile.lastName,
      dateOfBirth: dateOfBirth ?? currentProfile.dateOfBirth,
      photoUrl: photoUrl ?? currentProfile.photoUrl,
      email: currentProfile.email,
      twoStepEnabled: twoStepEnabled ?? currentProfile.twoStepEnabled,
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(updatedProfile.toMap(), SetOptions(merge: true));
  }

  Future<String> uploadImage(String imagePath) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Người dùng chưa đăng nhập');

    final storageRef = _storage.ref().child(
      'avatars/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.png',
    );

    final file = File(imagePath);
    await storageRef.putFile(file);
    return storageRef.getDownloadURL();
  }

  Future<String> uploadImageWeb(String base64String) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Người dùng chưa đăng nhập');

    final base64Data = base64String.split(',').last;
    final bytes = base64Decode(base64Data);

    final storageRef = _storage.ref().child(
      'avatars/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.png',
    );

    await storageRef.putData(bytes);
    return storageRef.getDownloadURL();
  }
}
