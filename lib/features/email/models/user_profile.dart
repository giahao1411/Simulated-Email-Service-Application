import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String phoneNumber;
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? photoUrl;
  final String? email;
  final bool? twoStepEnabled;

  UserProfile({
    required this.uid,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.photoUrl,
    this.email,
    this.twoStepEnabled,
  });

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      uid: data['uid'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      firstName: data['firstName'],
      lastName: data['lastName'],
      dateOfBirth:
          data['dateOfBirth'] != null
              ? (data['dateOfBirth'] as Timestamp).toDate()
              : null,
      photoUrl: data['photoUrl'],
      email: data['email'],
      twoStepEnabled: data['twoStepEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth':
          dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'photoUrl': photoUrl,
      'email': email,
      'twoStepEnabled': twoStepEnabled,
    };
  }
}
