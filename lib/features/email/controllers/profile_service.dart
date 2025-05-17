import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_application/features/email/models/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Getter public để truy cập _storage
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
    String? photoUrl,
    bool? twoStepEnabled,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Người dùng chưa đăng nhập');

    final data = <String, dynamic>{};
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (photoUrl != null) data['photoUrl'] = photoUrl;
    if (twoStepEnabled != null) data['twoStepEnabled'] = twoStepEnabled;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(data, SetOptions(merge: true));
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
}
