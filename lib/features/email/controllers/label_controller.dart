import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/features/email/controllers/auth_service.dart';

class LabelController {
  final CollectionReference _labelsRef = FirebaseFirestore.instance.collection(
    'labels',
  );
  final AuthService _authService = AuthService();
  String? uid;
  String? email;

  Future<void> initializeUserData() async {
    final userProfile = await _authService.currentUser;
    uid = userProfile?.uid ?? 'default_uid';
    email = userProfile?.email ?? 'default@example.com';
    AppFunctions.debugPrint(
      'Initialized user data for labels: UID=$uid, Email=$email',
    );
  }

  Future<List<String>> loadLabels() async {
    await initializeUserData();
    if (uid == 'default_uid') {
      AppFunctions.debugPrint('No user logged in, returning empty labels');
      return [];
    }
    try {
      final snapshot = await _labelsRef.where('uid', isEqualTo: uid).get();
      final labels = snapshot.docs.map((doc) => doc['name'] as String).toList();
      AppFunctions.debugPrint('Loaded labels for UID $uid: $labels');
      return labels;
    } on Exception catch (e) {
      AppFunctions.debugPrint('Error loading labels: $e');
      return [];
    }
  }

  Future<bool> doesLabelExist(String labelName) async {
    await initializeUserData();
    if (uid == 'default_uid') return false;
    try {
      final snapshot =
          await _labelsRef
              .where('uid', isEqualTo: uid)
              .where('name', isEqualTo: labelName)
              .limit(1)
              .get();
      return snapshot.docs.isNotEmpty;
    } on Exception catch (e) {
      AppFunctions.debugPrint('Error checking label existence: $e');
      return false;
    }
  }

  Future<bool> saveLabel(String label) async {
    await initializeUserData();
    if (uid == 'default_uid') {
      AppFunctions.debugPrint('Cannot save label: No user logged in');
      return false;
    }
    try {
      if (await doesLabelExist(label)) {
        AppFunctions.debugPrint('Label already exists: $label');
        return false;
      }
      await _labelsRef.add({'name': label, 'uid': uid, 'email': email});
      AppFunctions.debugPrint('Saved label: $label for UID: $uid');
      return true;
    } on Exception catch (e) {
      AppFunctions.debugPrint('Error saving label: $e');
      return false;
    }
  }

  Future<bool> updateLabel(String oldLabel, String newLabel) async {
    await initializeUserData();
    if (uid == 'default_uid') return false;
    try {
      if (await doesLabelExist(newLabel)) {
        AppFunctions.debugPrint('New label already exists: $newLabel');
        return false;
      }
      final snapshot =
          await _labelsRef
              .where('uid', isEqualTo: uid)
              .where('name', isEqualTo: oldLabel)
              .limit(1)
              .get();
      if (snapshot.docs.isNotEmpty) {
        await _labelsRef.doc(snapshot.docs.first.id).update({'name': newLabel});
        AppFunctions.debugPrint(
          'Updated label from $oldLabel to $newLabel for UID: $uid',
        );
        return true;
      }
      AppFunctions.debugPrint('Label not found: $oldLabel');
      return false;
    } on Exception catch (e) {
      AppFunctions.debugPrint('Error updating label: $e');
      return false;
    }
  }

  Future<bool> deleteLabel(String label) async {
    await initializeUserData();
    if (uid == 'default_uid') return false;
    try {
      final snapshot =
          await _labelsRef
              .where('uid', isEqualTo: uid)
              .where('name', isEqualTo: label)
              .limit(1)
              .get();
      if (snapshot.docs.isNotEmpty) {
        await _labelsRef.doc(snapshot.docs.first.id).delete();
        AppFunctions.debugPrint('Deleted label: $label for UID: $uid');
        return true;
      }
      AppFunctions.debugPrint('Label not found: $label');
      return false;
    } on Exception catch (e) {
      AppFunctions.debugPrint('Error deleting label: $e');
      return false;
    }
  }
}
