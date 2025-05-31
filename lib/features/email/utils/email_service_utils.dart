import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/features/email/models/draft.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/models/email_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class EmailServiceUtils {
  static final userEmail = FirebaseAuth.instance.currentUser?.email;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final Map<String, String> _fullNameCache = {};

  // Cập nhật danh bạ người dùng
  static Future<void> updateUserContacts({
    required String userId,
    required String from,
    required List<String> to,
    required List<String> cc,
    required List<String> bcc,
  }) async {
    try {
      final contactsDocRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('user_contacts')
          .doc('contacts');

      final contactsDoc = await contactsDocRef.get();
      final senders =
          contactsDoc.exists
              ? List<String>.from(
                (contactsDoc.data()?['senders'] ?? <String>[]) as Iterable,
              )
              : <String>[];
      final receivers =
          contactsDoc.exists
              ? List<String>.from(
                (contactsDoc.data()?['receivers'] ?? <String>[]) as Iterable,
              )
              : <String>[];

      if (from != userEmail) senders.add(from);
      receivers.addAll([...to, ...cc, ...bcc, if (from != userEmail) from]);

      await contactsDocRef.set({
        'senders': senders.toSet().toList(),
        'receivers': receivers.toSet().toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      AppFunctions.debugPrint('Đã cập nhật danh bạ cho userId: $userId');
    } on Exception catch (e) {
      AppFunctions.debugPrint('Lỗi khi cập nhật danh bạ: $e');
    }
  }

  static bool emailMatchesCategory(
    dynamic email,
    EmailState emailState,
    String category,
  ) {
    switch (category.toLowerCase()) {
      case 'inbox':
      case 'hộp thư đến':
        return email is Email &&
            (email.to.contains(userEmail) ||
                email.cc.contains(userEmail) ||
                email.bcc.contains(userEmail)) &&
            !emailState.trashed &&
            !emailState.hidden;
      case 'sent':
      case 'đã gửi':
        return email is Email &&
            email.from == userEmail &&
            !emailState.trashed &&
            !emailState.hidden;
      case 'draft':
      case 'drafts':
      case 'thư nháp':
        return email is Draft &&
            email.userId == FirebaseAuth.instance.currentUser!.uid;
      case 'starred':
      case 'có gắn dấu sao':
        return email is Email &&
            emailState.starred &&
            !emailState.trashed &&
            !emailState.hidden;
      case 'important':
      case 'quan trọng':
        return email is Email &&
            emailState.important &&
            !emailState.trashed &&
            !emailState.hidden;
      case 'spam':
      case 'thư rác':
        return email is Email &&
            emailState.spam &&
            !emailState.trashed &&
            !emailState.hidden;
      case 'hidden':
      case 'đã ẩn':
        return email is Email && emailState.hidden;
      case 'trash':
      case 'thùng rác':
        return email is Email && emailState.trashed;
      default:
        return email is Email &&
            emailState.labels.contains(category) &&
            !emailState.trashed &&
            !emailState.hidden;
    }
  }

  static Stream<List<Map<String, dynamic>>> getInboxEmails() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      AppFunctions.debugPrint('Không có người dùng đăng nhập');
      return Stream.value([]);
    }

    AppFunctions.debugPrint(
      'Bắt đầu lắng nghe email cho user: $userEmail (UID: ${user.uid})',
    );

    return _fetchEmailSnapshotsStream(userEmail).asyncMap((snapshots) async {
      try {
        final emailsWithState = await _processEmailSnapshots(
          userId: user.uid,
          snapshots: snapshots,
        );

        if (emailsWithState.isEmpty) {
          AppFunctions.debugPrint('Không có email nào trong hộp thư đến');
          return [];
        }

        // sort by timestamp descending
        emailsWithState.sort((a, b) {
          final aTimestamp = (a['email'] as Email).timestamp;
          final bTimestamp = (b['email'] as Email).timestamp;
          return bTimestamp.compareTo(aTimestamp);
        });

        AppFunctions.debugPrint(
          'Đã tìm thấy ${emailsWithState.length} email trong hộp thư đến',
        );
        return emailsWithState;
      } on Exception catch (e) {
        AppFunctions.debugPrint('Lỗi khi lắng nghe email: $e');
        return [];
      }
    });
  }

  // create snaphots stream from to, cc, bcc
  static Stream<List<QuerySnapshot>> _fetchEmailSnapshotsStream(
    String? userEmail,
  ) {
    final toStream =
        _firestore
            .collection('emails')
            .where('to', arrayContains: userEmail)
            .orderBy('timestamp', descending: true)
            .snapshots();

    final ccStream =
        _firestore
            .collection('emails')
            .where('cc', arrayContains: userEmail)
            .orderBy('timestamp', descending: true)
            .snapshots();

    final bccStream =
        _firestore
            .collection('emails')
            .where('bcc', arrayContains: userEmail)
            .orderBy('timestamp', descending: true)
            .snapshots();

    return CombineLatestStream.list([toStream, ccStream, bccStream]).doOnData((
      snapshots,
    ) {
      AppFunctions.debugPrint('toSnapshot: ${snapshots[0].docs.length} emails');
      AppFunctions.debugPrint('ccSnapshot: ${snapshots[1].docs.length} emails');
      AppFunctions.debugPrint(
        'bccSnapshot: ${snapshots[2].docs.length} emails',
      );
    });
  }

  // process email snapshots and merge them
  static Future<List<Map<String, dynamic>>> _processEmailSnapshots({
    required String userId,
    required List<QuerySnapshot> snapshots,
  }) async {
    final emailWithState = <Map<String, dynamic>>[];
    final seenIds = <String>{};

    for (final snapshot in snapshots) {
      for (final doc in snapshot.docs) {
        final emailData = await _processSingleEmail(
          userId: userId,
          doc: doc,
          seenIds: seenIds,
        );
        if (emailData != null) {
          emailWithState.add(emailData);
        }
      }
    }
    return emailWithState;
  }

  static Future<Map<String, dynamic>?> _processSingleEmail({
    required String userId,
    required QueryDocumentSnapshot doc,
    required Set<String> seenIds,
  }) async {
    final docId = doc.id;
    // Filter out duplicate emails
    if (seenIds.contains(docId)) {
      AppFunctions.debugPrint('Bỏ qua email trùng lặp: $docId');
      return null;
    }
    seenIds.add(docId);

    final data = doc.data() as Map<String, dynamic>?;
    if (data == null || data.isEmpty) {
      AppFunctions.debugPrint('Bỏ qua tài liệu rỗng: $docId');
      return null;
    }

    try {
      final email = Email.fromMap(docId, data);
      final emailState = await _fetchEmailState(userId, email.id);
      // Check trashed and hidden state
      if (emailState.trashed) {
        AppFunctions.debugPrint('Bỏ qua email ${email.id} vì trong thùng rác');
        return null;
      }
      if (emailState.hidden) {
        AppFunctions.debugPrint('Bỏ qua email ${email.id} vì bị ẩn');
        return null;
      }

      final senderFullName = await getUserFullNameByEmail(email.from);
      AppFunctions.debugPrint('Thêm email: ${email.id}');

      return {
        'email': email,
        'state': emailState,
        'senderFullName': senderFullName,
      };
    } on Exception catch (e) {
      AppFunctions.debugPrint('Lỗi khi xử lý email $docId: $e');
      return null;
    }
  }

  static Future<EmailState> _fetchEmailState(
    String userId,
    String emailId,
  ) async {
    final stateDoc =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('email_states')
            .doc(emailId)
            .get();
    return stateDoc.exists
        ? EmailState.fromMap(stateDoc.data()!)
        : EmailState(emailId: emailId);
  }

  static Future<String> getUserFullNameByEmail(String email) async {
    if (_fullNameCache.containsKey(email)) {
      return _fullNameCache[email]!;
    }
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
          _fullNameCache[email] = fullName;
          return fullName;
        }
      }
      _fullNameCache[email] = email;
      return email;
    } on Exception catch (e) {
      AppFunctions.debugPrint('Lỗi khi lấy tên người dùng: $e');
      _fullNameCache[email] = email;
      return email;
    }
  }
}
