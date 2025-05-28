import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/features/email/models/email_state.dart';
import 'package:email_application/features/email/utils/email_service_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DraftService {
  final userEmail = FirebaseAuth.instance.currentUser?.email;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveDraft({
    required List<String> to,
    required List<String> cc,
    required List<String> bcc,
    required String subject,
    required String body,
    String? id,
  }) async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        throw Exception('Chưa đăng nhập để lưu thư nháp');
      }
      final userId = FirebaseAuth.instance.currentUser!.uid;

      final draftRef = await _firestore.collection('drafts').add({
        'userId': userId,
        'to': to,
        'cc': cc,
        'bcc': bcc,
        'subject': subject,
        'body': body,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('email_states')
          .doc(draftRef.id)
          .set(EmailState(emailId: draftRef.id).toMap());

      // Cập nhật danh bạ cho người gửi
      await EmailServiceUtils.updateUserContacts(
        userId: userId,
        from: userEmail ?? '',
        to: to,
        cc: cc,
        bcc: bcc,
      );
    } on Exception catch (e) {
      AppFunctions.debugPrint('Lỗi khi lưu thư nháp: $e');
      throw Exception('Lỗi khi lưu thư nháp: $e');
    }
  }

  Future<void> deleteDraft(String emailId) async {
    try {
      await _firestore.collection('drafts').doc(emailId).delete();
      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('email_states')
          .doc(emailId)
          .delete();
    } catch (e) {
      AppFunctions.debugPrint('Lỗi khi xóa thư nháp: $e');
      throw Exception('Không thể xóa thư nháp: $e');
    }
  }
}
