class UserProfile {
  final String uid;
  final String phoneNumber;
  String? displayName;
  String? photoUrl;

  UserProfile({
    required this.uid,
    required this.phoneNumber,
    this.displayName,
    this.photoUrl,
  });

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    return UserProfile(
      uid: data['uid'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }
}
