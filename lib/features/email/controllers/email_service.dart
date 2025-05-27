import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/core/constants/app_strings.dart';
import 'package:email_application/features/email/models/draft.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/models/email_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailService {
  EmailService() : userEmail = FirebaseAuth.instance.currentUser?.email;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userEmail;

  Stream<List<Map<String, dynamic>>> getEmails(String category) {
    if (userEmail == null || FirebaseAuth.instance.currentUser == null) {
      AppFunctions.debugPrint('Không truy vấn email vì chưa đăng nhập');
      return Stream.value([]);
    }

    AppFunctions.debugPrint('Lấy email cho danh mục: $category');

    if (category == AppStrings.inbox) {
      return _getInboxEmails();
    }

    var query = _firestore
        .collection(category == AppStrings.drafts ? 'drafts' : 'emails')
        .orderBy('timestamp', descending: true);

    if (category == AppStrings.sent) {
      query = query.where('from', isEqualTo: userEmail);
    } else if (category == AppStrings.drafts) {
      query = query.where(
        'userId',
        isEqualTo: FirebaseAuth.instance.currentUser!.uid,
      );
    }

    return query.snapshots().asyncMap((snapshot) async {
      try {
        final emailsWithState = <Map<String, dynamic>>[];
        for (final doc in snapshot.docs) {
          final data = doc.data();
          if (data.isEmpty) continue;

          final email = Email.fromMap(doc.id, data);
          final stateDoc =
              await _firestore
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('email_states')
                  .doc(email.id)
                  .get();
          final emailState =
              stateDoc.exists
                  ? EmailState.fromMap(stateDoc.data()!)
                  : EmailState(emailId: email.id);

          if (category == AppStrings.starred && !emailState.starred) continue;
          if (category == AppStrings.trash && !emailState.trashed) continue;
          if (category != AppStrings.starred &&
              category != AppStrings.trash &&
              category != AppStrings.inbox &&
              category != AppStrings.sent &&
              category != AppStrings.drafts &&
              !emailState.labels.contains(category)) {
            continue;
          }

          emailsWithState.add({'email': email, 'state': emailState});
        }
        return emailsWithState;
      } on Exception catch (e) {
        AppFunctions.debugPrint('Lỗi khi ánh xạ dữ liệu email: $e');
        return <Map<String, dynamic>>[];
      }
    });
  }

  Stream<List<Map<String, dynamic>>> _getInboxEmails() {
    if (userEmail == null) {
      AppFunctions.debugPrint('Không lấy email inbox vì userEmail null');
      return Stream.value([]);
    }

    return Stream<void>.periodic(const Duration(seconds: 5)).asyncMap((
      _,
    ) async {
      try {
        final toSnapshot =
            await _firestore
                .collection('emails')
                .where('to', arrayContains: userEmail)
                .orderBy('timestamp', descending: true)
                .get();
        final ccSnapshot =
            await _firestore
                .collection('emails')
                .where('cc', arrayContains: userEmail)
                .orderBy('timestamp', descending: true)
                .get();
        final bccSnapshot =
            await _firestore
                .collection('emails')
                .where('bcc', arrayContains: userEmail)
                .orderBy('timestamp', descending: true)
                .get();

        final emailsWithState = <Map<String, dynamic>>[];
        final seenIds = <String>{};

        for (final snapshot in [toSnapshot, ccSnapshot, bccSnapshot]) {
          for (final doc in snapshot.docs) {
            if (seenIds.contains(doc.id)) continue;
            seenIds.add(doc.id);

            final data = doc.data();
            if (data.isEmpty) continue;

            final email = Email.fromMap(doc.id, data);
            final stateDoc =
                await _firestore
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('email_states')
                    .doc(email.id)
                    .get();
            final emailState =
                stateDoc.exists
                    ? EmailState.fromMap(stateDoc.data()!)
                    : EmailState(emailId: email.id);

            emailsWithState.add({'email': email, 'state': emailState});
          }
        }

        emailsWithState.sort((a, b) {
          final aTimestamp = (a['email'] as Email).timestamp;
          final bTimestamp = (b['email'] as Email).timestamp;
          return bTimestamp.compareTo(aTimestamp);
        });

        AppFunctions.debugPrint(
          'Trả về ${emailsWithState.length} email cho inbox',
        );
        return emailsWithState;
      } on Exception catch (e) {
        AppFunctions.debugPrint('Lỗi khi ánh xạ dữ liệu inbox: $e');
        return <Map<String, dynamic>>[];
      }
    });
  }

  Future<void> sendEmail({
    required List<String> to,
    required List<String> cc,
    required List<String> bcc,
    required String subject,
    required String body,
  }) async {
    try {
      if (userEmail == null) {
        throw Exception('Chưa đăng nhập để gửi email');
      }

      // add email to collection 'emails'
      final emailRef = await _firestore.collection('emails').add({
        'from': userEmail,
        'to': to,
        'cc': cc,
        'bcc': bcc,
        'subject': subject,
        'body': body,
        'timestamp': FieldValue.serverTimestamp(),
        'isDraft': false,
      });

      // create email state
      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('email_states')
          .doc(emailRef.id)
          .set(EmailState(emailId: emailRef.id).toMap());

      // create email for each recipient
      final allRecipients =
          <dynamic>{...to, ...cc, ...bcc}.toList(); // filter duplicates
      for (final recipientEmail in allRecipients) {
        final userQuery =
            await _firestore
                .collection('users')
                .where('email', isEqualTo: recipientEmail)
                .limit(1)
                .get();
        if (userQuery.docs.isNotEmpty) {
          final recipientUid = userQuery.docs.first.id;
          await _firestore
              .collection('users')
              .doc(recipientUid)
              .collection('email_states')
              .doc(emailRef.id)
              .set(EmailState(emailId: emailRef.id).toMap());
        }
      }
    } on Exception catch (e) {
      AppFunctions.debugPrint('Lỗi khi gửi email: $e');
      throw Exception('Lỗi khi gửi email: $e');
    }
  }

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

      // create a new draft
      final draft = Draft(
        id: '',
        userId: userId,
        to: to,
        cc: cc,
        bcc: bcc,
        subject: subject,
        body: body,
        timestamp: DateTime.now(),
      );

      final draftRef = await _firestore.collection('drafts').add(draft.toMap());

      // create state for draft
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('email_states')
          .doc(draftRef.id)
          .set(EmailState(emailId: draftRef.id).toMap());
    } on Exception catch (e) {
      AppFunctions.debugPrint('Lỗi khi lưu thư nháp: $e');
      throw Exception('Lỗi khi lưu thư nháp: $e');
    }
  }

  Future<void> toggleStar(String emailId, bool currentStatus) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final stateDoc =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('email_states')
              .doc(emailId)
              .get();
      final emailState =
          stateDoc.exists
              ? EmailState.fromMap(stateDoc.data()!)
              : EmailState(emailId: emailId);

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('email_states')
          .doc(emailId)
          .set(emailState.copyWith(starred: !currentStatus).toMap());
    } catch (e) {
      AppFunctions.debugPrint('Lỗi khi thay đổi trạng thái sao: $e');
      throw Exception('Không thể thay đổi trạng thái sao: $e');
    }
  }

  Future<void> toggleRead(String emailId, bool currentStatus) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final stateDoc =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('email_states')
              .doc(emailId)
              .get();
      final emailState =
          stateDoc.exists
              ? EmailState.fromMap(stateDoc.data()!)
              : EmailState(emailId: emailId);

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('email_states')
          .doc(emailId)
          .set(emailState.copyWith(read: !currentStatus).toMap());
    } catch (e) {
      AppFunctions.debugPrint('Lỗi khi thay đổi trạng thái đã đọc: $e');
      throw Exception('Không thể thay đổi trạng thái đã đọc: $e');
    }
  }

  Future<void> addLabel(String emailId, String label) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final stateDoc =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('email_states')
              .doc(emailId)
              .get();
      final emailState =
          stateDoc.exists
              ? EmailState.fromMap(stateDoc.data()!)
              : EmailState(emailId: emailId);

      final updatedLabels = List<String>.from(emailState.labels)..add(label);
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('email_states')
          .doc(emailId)
          .set(emailState.copyWith(labels: updatedLabels).toMap());
    } catch (e) {
      AppFunctions.debugPrint('Lỗi khi thêm nhãn: $e');
      throw Exception('Không thể thêm nhãn: $e');
    }
  }

  Future<void> moveToTrash(String emailId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final stateDoc =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('email_states')
              .doc(emailId)
              .get();
      final emailState =
          stateDoc.exists
              ? EmailState.fromMap(stateDoc.data()!)
              : EmailState(emailId: emailId);

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('email_states')
          .doc(emailId)
          .set(emailState.copyWith(trashed: true).toMap());
    } catch (e) {
      AppFunctions.debugPrint('Lỗi khi chuyển vào thùng rác: $e');
      throw Exception('Không thể chuyển vào thùng rác: $e');
    }
  }

  Future<int> countUnreadEmails() async {
    try {
      final snapshot =
          await _firestore
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('email_states')
              .where('read', isEqualTo: false)
              .get();
      return snapshot.docs.length;
    } catch (e) {
      AppFunctions.debugPrint('Lỗi khi đếm email chưa đọc: $e');
      throw Exception('Không thể đếm email chưa đọc: $e');
    }
  }

  Future<String> getUserFullNameByEmail(String email) async {
    try {
      final query =
          await _firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();
      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        final firstName = (data['firstName'] ?? '') as String;
        final lastName = (data['lastName'] ?? '') as String;
        final fullName = '$firstName $lastName'.trim();
        if (fullName.isNotEmpty) {
          return fullName;
        }
      }
      return email;
    } on Exception catch (e) {
      AppFunctions.debugPrint('Lỗi khi lấy tên người dùng: $e');
      return email;
    }
  }

  // hard delete email
  Future<void> deleteEmail(String emailId) async {
    try {
      await _firestore.collection('emails').doc(emailId).delete();
      await _firestore.collection('drafts').doc(emailId).delete();
      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('email_states')
          .doc(emailId)
          .delete();
    } catch (e) {
      AppFunctions.debugPrint('Lỗi khi xóa email: $e');
      throw Exception('Không thể xóa email: $e');
    }
  }

  // hard delete draft
  Future<void> deleteDraft(String draftId) async {
    try {
      await _firestore.collection('drafts').doc(draftId).delete();
      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('email_states')
          .doc(draftId)
          .delete();
    } catch (e) {
      AppFunctions.debugPrint('Lỗi khi xóa thư nháp: $e');
      throw Exception('Không thể xóa thư nháp: $e');
    }
  }
}
