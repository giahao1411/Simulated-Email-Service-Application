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
    List<Map<String, dynamic>>? attachments,
  }) async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        throw Exception('Chưa đăng nhập để lưu thư nháp');
      }
      final userId = FirebaseAuth.instance.currentUser!.uid;

      final draftData = {
        'userId': userId,
        'to': to,
        'cc': cc,
        'bcc': bcc,
        'subject': subject,
        'body': body,
        'timestamp': FieldValue.serverTimestamp(),
        'attachments': attachments ?? [],
      };

      String draftId;
      if (id == null) {
        final newDraft = await _firestore.collection('drafts').add(draftData);
        draftId = newDraft.id;
      } else {
        draftId = id;
        await _firestore
            .collection('drafts')
            .doc(id)
            .set(draftData, SetOptions(merge: true));
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('email_states')
          .doc(draftId)
          .set(EmailState(emailId: draftId, read: true).toMap());

      await EmailServiceUtils.updateUserContacts(
        userId: userId,
        from: userEmail ?? '',
        to: to,
        cc: cc,
        bcc: bcc,
      );

      AppFunctions.debugPrint(
        'Draft saved successfully with id: $draftId, body: $body',
      );
    } on Exception catch (e) {
      AppFunctions.debugPrint('Lỗi khi lưu thư nháp: $e');
      throw Exception('Lỗi khi lưu thư nháp: $e');
    }
  }

  Future<void> deleteDraft(String draftId) async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        throw Exception('Chưa đăng nhập để xóa thư nháp');
      }

      await _firestore.collection('drafts').doc(draftId).delete();
      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('email_states')
          .doc(draftId)
          .delete();

      AppFunctions.debugPrint('Xóa nháp thành công: $draftId');
    } catch (e) {
      AppFunctions.debugPrint('Lỗi khi xóa thư nháp: $e');
      throw Exception('Không thể xóa thư nháp: $e');
    }
  }
}
