import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String phoneNumber;
  final String? displayName;
  final String? photoUrl;
  final String? email;

  UserProfile({
    required this.uid,
    required this.phoneNumber,
    this.displayName,
    this.photoUrl,
    this.email,
  });

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      uid: data['uid'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      email: data['email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'email': email,
    };
  }
}
