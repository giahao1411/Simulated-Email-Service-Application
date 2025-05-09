import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateProfile(String displayName, String? photoUrl) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'phoneNumber': user.phoneNumber,
        'displayName': displayName,
        'photoUrl': photoUrl,
      }, SetOptions(merge: true));
    }
  }

  Future<UserProfile?> getProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      }
    }
    return null;
  }
}
