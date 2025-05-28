import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/core/constants/app_strings.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/models/email_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    Email email,
    EmailState emailState,
    String category,
  ) {
    switch (category.toLowerCase()) {
      case 'inbox':
        return email.to.contains(userEmail) ||
            email.cc.contains(userEmail) ||
            email.bcc.contains(userEmail);
      case 'sent':
        return email.from == userEmail;
      case 'draft':
      case 'drafts':
        return email.userId != null &&
            email.userId == FirebaseAuth.instance.currentUser!.uid;
      case 'starred':
        return emailState.starred;
      case 'important':
        return emailState.important;
      case 'spam':
        return emailState.spam;
      case 'hidden':
        return emailState.hidden;
      case 'trash':
        return emailState.trashed;
      default:
        return emailState.labels.contains(category);
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

    final toStream = _firestore
        .collection('emails')
        .where('to', arrayContains: userEmail)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => {'source': 'to', 'snapshot': snapshot});

    final ccStream = _firestore
        .collection('emails')
        .where('cc', arrayContains: userEmail)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => {'source': 'cc', 'snapshot': snapshot});

    final bccStream = _firestore
        .collection('emails')
        .where('bcc', arrayContains: userEmail)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => {'source': 'bcc', 'snapshot': snapshot});

    final stateStream =
        _firestore
            .collection('users')
            .doc(user.uid)
            .collection('email_states')
            .snapshots();

    return StreamGroup.merge([
      toStream,
      ccStream,
      bccStream,
      stateStream,
    ]).asyncMap((sourceData) async {
      try {
        final emailsWithState = <Map<String, dynamic>>[];
        final seenIds = <String>{};

        if (sourceData is QuerySnapshot) {
          AppFunctions.debugPrint(
            'Nhận snapshot từ email_states: ${sourceData.docs.length} tài liệu',
          );
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

          AppFunctions.debugPrint(
            'toSnapshot: ${toSnapshot.docs.length} emails',
          );
          AppFunctions.debugPrint(
            'ccSnapshot: ${ccSnapshot.docs.length} emails',
          );
          AppFunctions.debugPrint(
            'bccSnapshot: ${bccSnapshot.docs.length} emails',
          );

          for (final snapshot in [toSnapshot, ccSnapshot, bccSnapshot]) {
            for (final doc in snapshot.docs) {
              final docId = doc.id;
              if (seenIds.contains(docId)) {
                AppFunctions.debugPrint(
                  'Bỏ qua email trùng lặp: $docId (từ snapshot cache)',
                );
                continue;
              }
              seenIds.add(docId);

              final data = doc.data();
              if (data.isEmpty) {
                AppFunctions.debugPrint(
                  'Bỏ qua tài liệu rỗng: $docId (từ snapshot cache)',
                );
                continue;
              }

              try {
                final email = Email.fromMap(docId, data);
                final stateDoc =
                    await _firestore
                        .collection('users')
                        .doc(user.uid)
                        .collection('email_states')
                        .doc(email.id)
                        .get();
                final emailState =
                    stateDoc.exists
                        ? EmailState.fromMap(stateDoc.data()!)
                        : EmailState(emailId: email.id);

                final senderFullName = await getUserFullNameByEmail(email.from);

                if (emailState.trashed && AppStrings.trash != 'Inbox') {
                  AppFunctions.debugPrint(
                    'Bỏ qua email ${email.id} vì trong thùng rác',
                  );
                  continue;
                }
                if (emailState.hidden && AppStrings.hidden != 'Inbox') {
                  AppFunctions.debugPrint('Bỏ qua email ${email.id} vì bị ẩn');
                  continue;
                }

                emailsWithState.add({
                  'email': email,
                  'state': emailState,
                  'senderFullName': senderFullName,
                });
                AppFunctions.debugPrint(
                  'Thêm email: ${email.id} (từ snapshot cache)',
                );
              } on Exception catch (e) {
                AppFunctions.debugPrint(
                  'Lỗi khi xử lý email $docId (từ snapshot cache): $e',
                );
                continue;
              }
            }
          }
        } else {
          final dataMap = sourceData as Map<String, dynamic>;
          final source = dataMap['source'] as String;
          final snapshot = dataMap['snapshot'] as QuerySnapshot;

          AppFunctions.debugPrint(
            'Nhận snapshot từ $source: ${snapshot.docs.length} tài liệu',
          );

          for (final doc in snapshot.docs) {
            final docId = doc.id;
            if (seenIds.contains(docId)) {
              AppFunctions.debugPrint(
                'Bỏ qua email trùng lặp: $docId (từ $source)',
              );
              continue;
            }
            seenIds.add(docId);

            final data = doc.data()! as Map<String, dynamic>;
            if (data.isEmpty) {
              AppFunctions.debugPrint(
                'Bỏ qua tài liệu rỗng: $docId (từ $source)',
              );
              continue;
            }

            try {
              final email = Email.fromMap(docId, data);
              final stateDoc =
                  await _firestore
                      .collection('users')
                      .doc(user.uid)
                      .collection('email_states')
                      .doc(email.id)
                      .get();
              final emailState =
                  stateDoc.exists
                      ? EmailState.fromMap(stateDoc.data()!)
                      : EmailState(emailId: email.id);

              final senderFullName = await getUserFullNameByEmail(email.from);

              if (emailState.trashed && AppStrings.trash != 'Inbox') {
                AppFunctions.debugPrint(
                  'Bỏ qua email ${email.id} vì trong thùng rác',
                );
                continue;
              }
              if (emailState.hidden && AppStrings.hidden != 'Inbox') {
                AppFunctions.debugPrint('Bỏ qua email ${email.id} vì bị ẩn');
                continue;
              }

              emailsWithState.add({
                'email': email,
                'state': emailState,
                'senderFullName': senderFullName,
              });
              AppFunctions.debugPrint('Thêm email: ${email.id} (từ $source)');
            } on Exception catch (e) {
              AppFunctions.debugPrint(
                'Lỗi khi xử lý email $docId (từ $source): $e',
              );
              continue;
            }
          }
        }

        if (emailsWithState.isEmpty) {
          AppFunctions.debugPrint('Danh sách email rỗng cho hộp thư đến');
          return [];
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
        return [];
      }
    });
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
