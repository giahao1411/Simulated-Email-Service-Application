import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
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
      uid: data['uid'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      firstName: data['firstName'] as String?,
      lastName: data['lastName'] as String?,
      dateOfBirth:
          data['dateOfBirth'] != null
              ? (data['dateOfBirth'] as Timestamp).toDate()
              : null,
      photoUrl: data['photoUrl'] as String?,
      email: data['email'] as String?,
      twoStepEnabled: data['twoStepEnabled'] as bool? ?? false,
    );
  }
  final String uid;
  final String phoneNumber;
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? photoUrl;
  final String? email;
  final bool? twoStepEnabled;

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
      'autoReplyEnabled': false,
      'autoReplyMessage':
          'Cảm ơn bạn đã gửi email cho tôi. Tôi sẽ trả lời bạn sớm nhất có thể.',
      'autoReplyTime': 5,
    };
  }
}
