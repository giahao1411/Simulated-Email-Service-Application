import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_application/features/email/models/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseStorage get storage => _storage;

  Future<UserProfile?> getProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.exists ? UserProfile.fromMap(doc.data()!) : null;
    } catch (e) {
      debugPrint('Error getting profile: $e');
      return null;
    }
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

    try {
      final storageRef = _storage.ref().child(
        'avatars/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.png',
      );

      final file = File(imagePath);

      // Thêm metadata cho CORS
      final metadata = SettableMetadata(
        contentType: 'image/png',
        customMetadata: {
          'uploaded_by': user.uid,
          'upload_time': DateTime.now().toIso8601String(),
        },
      );

      await storageRef.putFile(file, metadata);
      return await storageRef.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading image: $e');
      rethrow;
    }
  }

  Future<String> uploadImageWeb(String base64String) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Người dùng chưa đăng nhập');

    try {
      final base64Data = base64String.split(',').last;
      final bytes = base64Decode(base64Data);

      final storageRef = _storage.ref().child(
        'avatars/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.png',
      );

      // Thêm metadata cho web
      final metadata = SettableMetadata(
        contentType: 'image/png',
        cacheControl: 'public, max-age=3600',
        customMetadata: {
          'uploaded_by': user.uid,
          'upload_time': DateTime.now().toIso8601String(),
          'platform': 'web',
        },
      );

      await storageRef.putData(bytes, metadata);
      final downloadUrl = await storageRef.getDownloadURL();

      // Thêm cache busting parameter cho web
      if (kIsWeb) {
        return '$downloadUrl&t=${DateTime.now().millisecondsSinceEpoch}';
      }

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image web: $e');
      rethrow;
    }
  }

  // Thêm method để validate URL trước khi sử dụng
  Future<bool> isImageUrlValid(String url) async {
    if (kIsWeb) {
      // Trên web, có thể test bằng cách tạo Image widget tạm
      try {
        // Simple check - nếu URL format đúng
        final uri = Uri.parse(url);
        return uri.isAbsolute && uri.scheme.startsWith('http');
      } catch (e) {
        return false;
      }
    }
    return true; // Mobile luôn return true
  }

  // Method để lấy URL với fallback
  Future<String?> getSafeImageUrl(String? photoUrl) async {
    if (photoUrl == null || photoUrl.isEmpty) return null;

    if (await isImageUrlValid(photoUrl)) {
      return photoUrl;
    }

    return null; // Return null nếu URL không valid
  }
}
