import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/core/constants/app_strings.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/models/email_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailService {
  EmailService() : userEmail = FirebaseAuth.instance.currentUser?.email;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userEmail;
  final Map<String, String> _fullNameCache = {};

  // Cập nhật danh bạ người dùng
  Future<void> _updateUserContacts({
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
    } catch (e) {
      AppFunctions.debugPrint('Lỗi khi cập nhật danh bạ: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> searchEmails({
    String? searchKeyword,
    String? category,
    String? fromEmail,
    String? toEmail,
    bool? hasText,
    DateTimeRange? dateRange,
  }) {
    if (userEmail == null || FirebaseAuth.instance.currentUser == null) {
      AppFunctions.debugPrint('Không truy vấn email vì chưa đăng nhập');
      return Stream.value([]);
    }

    AppFunctions.debugPrint(
      'Tìm kiếm email với: keyword=$searchKeyword, category=$category, from=$fromEmail, to=$toEmail, hasText=$hasText, dateRange=$dateRange',
    );

    Stream<List<Map<String, dynamic>>> emailStream =
        category != null && category.isNotEmpty
            ? getEmails(category)
            : getAllEmails();

    return emailStream.asyncMap((allEmails) async {
      final filteredEmails = <Map<String, dynamic>>[];

      for (final emailData in allEmails) {
        final email = emailData['email'] as Email;
        final emailState = emailData['state'] as EmailState;
        bool shouldInclude = true;

        if (searchKeyword != null && searchKeyword.isNotEmpty) {
          final keyword = searchKeyword.toLowerCase();
          final matchesSubject = email.subject.toLowerCase().contains(keyword);
          final matchesBody = email.body.toLowerCase().contains(keyword);
          final matchesFrom = email.from.toLowerCase().contains(keyword);
          final matchesToList = email.to.any(
            (to) => to.toLowerCase().contains(keyword),
          );
          final matchesCcList = email.cc.any(
            (cc) => cc.toLowerCase().contains(keyword),
          );
          final matchesBccList = email.bcc.any(
            (bcc) => bcc.toLowerCase().contains(keyword),
          );

          if (!matchesSubject &&
              !matchesBody &&
              !matchesFrom &&
              !matchesToList &&
              !matchesCcList &&
              !matchesBccList) {
            shouldInclude = false;
            AppFunctions.debugPrint(
              'Email ${email.id} không khớp với từ khóa: $searchKeyword',
            );
          }
        }

        if (shouldInclude && fromEmail != null && fromEmail.isNotEmpty) {
          shouldInclude = email.from.toLowerCase().contains(
            fromEmail.toLowerCase(),
          );
          if (!shouldInclude) {
            AppFunctions.debugPrint(
              'Email ${email.id} không khớp với người gửi: $fromEmail',
            );
          }
        }

        if (shouldInclude && toEmail != null && toEmail.isNotEmpty) {
          shouldInclude =
              email.to.any(
                (to) => to.toLowerCase().contains(toEmail.toLowerCase()),
              ) ||
              email.cc.any(
                (cc) => cc.toLowerCase().contains(toEmail.toLowerCase()),
              ) ||
              email.bcc.any(
                (bcc) => bcc.toLowerCase().contains(toEmail.toLowerCase()),
              );
          if (!shouldInclude) {
            AppFunctions.debugPrint(
              'Email ${email.id} không khớp với người nhận: $toEmail',
            );
          }
        }

        if (shouldInclude && hasText != null) {
          shouldInclude = email.body.isNotEmpty == hasText;
          if (!shouldInclude) {
            AppFunctions.debugPrint(
              'Email ${email.id} không khớp với điều kiện văn bản: $hasText',
            );
          }
        }

        if (shouldInclude && dateRange != null) {
          final emailDate = email.timestamp;
          shouldInclude =
              emailDate.isAfter(
                dateRange.start.subtract(const Duration(days: 1)),
              ) &&
              emailDate.isBefore(dateRange.end.add(const Duration(days: 1)));
          if (!shouldInclude) {
            AppFunctions.debugPrint(
              'Email ${email.id} không khớp với khoảng ngày: $dateRange',
            );
          }
        }

        if (shouldInclude && category != null && category.isNotEmpty) {
          shouldInclude = _emailMatchesCategory(email, emailState, category);
          if (!shouldInclude) {
            AppFunctions.debugPrint(
              'Email ${email.id} không thuộc nhãn: $category',
            );
          }
        }

        if (shouldInclude) {
          filteredEmails.add(emailData);
          AppFunctions.debugPrint(
            'Thêm email ${email.id} vào kết quả tìm kiếm',
          );
        }
      }

      filteredEmails.sort((a, b) {
        final aTimestamp = (a['email'] as Email).timestamp;
        final bTimestamp = (b['email'] as Email).timestamp;
        return bTimestamp.compareTo(aTimestamp);
      });

      AppFunctions.debugPrint(
        'Tìm thấy ${filteredEmails.length} email phù hợp',
      );
      return filteredEmails;
    });
  }

  bool _emailMatchesCategory(
    Email email,
    EmailState emailState,
    String category,
  ) {
    switch (category.toLowerCase()) {
      case 'inbox':
        return (email.to.contains(userEmail) ||
            email.cc.contains(userEmail) ||
            email.bcc.contains(userEmail));
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

  Stream<List<Map<String, dynamic>>> getEmails(String category) {
    if (userEmail == null || FirebaseAuth.instance.currentUser == null) {
      AppFunctions.debugPrint('Không truy vấn email vì chưa đăng nhập');
      return Stream.value([]);
    }

    AppFunctions.debugPrint('Lấy email cho danh mục: $category');

    if (category.toLowerCase() == AppStrings.inbox.toLowerCase() ||
        category == 'Inbox') {
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

          final senderFullName = await getUserFullNameByEmail(email.from);

          AppFunctions.debugPrint(
            'Checking email ${email.id} - important: ${emailState.important}, hidden: ${emailState.hidden}, trashed: ${emailState.trashed}, labels: ${emailState.labels}',
          );

          bool shouldInclude = _emailMatchesCategory(
            email,
            emailState,
            category,
          );

          if (!shouldInclude) {
            AppFunctions.debugPrint(
              'Bỏ qua email ${email.id} vì không thuộc danh mục: $category',
            );
            continue;
          }

          emailsWithState.add({
            'email': email,
            'state': emailState,
            'senderFullName': senderFullName,
          });
        }

        if (emailsWithState.isEmpty) {
          AppFunctions.debugPrint(
            'Danh sách email rỗng cho danh mục: $category',
          );
        } else {
          AppFunctions.debugPrint(
            'Found ${emailsWithState.length} emails in category "$category"',
          );
        }
        return emailsWithState;
      } on Exception catch (e) {
        AppFunctions.debugPrint('Lỗi khi ánh xạ dữ liệu email: $e');
        return <Map<String, dynamic>>[];
      }
    });
  }

  Stream<List<Map<String, dynamic>>> getAllEmails() {
    if (userEmail == null || FirebaseAuth.instance.currentUser == null) {
      AppFunctions.debugPrint('Không truy vấn email vì chưa đăng nhập');
      return Stream.value([]);
    }

    AppFunctions.debugPrint('Lấy tất cả email cho user: $userEmail');

    final emailsStream =
        _firestore
            .collection('emails')
            .orderBy('timestamp', descending: true)
            .snapshots();

    final draftsStream =
        _firestore
            .collection('drafts')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .orderBy('timestamp', descending: true)
            .snapshots();

    final stateStream =
        _firestore
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('email_states')
            .snapshots();

    return StreamGroup.merge([
      emailsStream,
      draftsStream,
      stateStream,
    ]).asyncMap((snapshot) async {
      try {
        final emailsWithState = <Map<String, dynamic>>[];
        final seenIds = <String>{};

        for (final doc in snapshot.docs) {
          final docId = doc.id;
          if (seenIds.contains(docId)) continue;
          seenIds.add(docId);

          final data = doc.data();
          if (data.isEmpty) continue;

          final email = Email.fromMap(docId, data);
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

          final senderFullName = await getUserFullNameByEmail(email.from);

          emailsWithState.add({
            'email': email,
            'state': emailState,
            'senderFullName': senderFullName,
          });
        }

        if (emailsWithState.isEmpty) {
          AppFunctions.debugPrint('Danh sách tất cả email rỗng');
        } else {
          AppFunctions.debugPrint(
            'Tìm thấy ${emailsWithState.length} email trong tất cả danh mục',
          );
        }

        emailsWithState.sort((a, b) {
          final aTimestamp = (a['email'] as Email).timestamp;
          final bTimestamp = (b['email'] as Email).timestamp;
          return bTimestamp.compareTo(aTimestamp);
        });

        return emailsWithState;
      } on Exception catch (e) {
        AppFunctions.debugPrint('Lỗi khi lấy tất cả email: $e');
        return <Map<String, dynamic>>[];
      }
    });
  }

  Stream<List<Map<String, dynamic>>> _getInboxEmails() {
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

      final emailRef = await _firestore.collection('emails').add({
        'from': userEmail,
        'to': to,
        'cc': cc,
        'bcc': bcc,
        'subject': subject,
        'body': body,
        'timestamp': FieldValue.serverTimestamp(),
        'isDraft': false,
        'hasAttachments': false,
      });

      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('email_states')
          .doc(emailRef.id)
          .set(EmailState(emailId: emailRef.id).toMap());

      final allRecipients = <String>{...to, ...cc, ...bcc}.toList();
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

          // Cập nhật danh bạ cho người nhận
          await _updateUserContacts(
            userId: recipientUid,
            from: userEmail!,
            to: to,
            cc: cc,
            bcc: bcc,
          );
        }
      }

      // Cập nhật danh bạ cho người gửi
      await _updateUserContacts(
        userId: FirebaseAuth.instance.currentUser!.uid,
        from: userEmail!,
        to: to,
        cc: cc,
        bcc: bcc,
      );
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
      await _updateUserContacts(
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

  Future<void> toggleRead(String emailId, bool currentReadState) async {
    try {
      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('email_states')
          .doc(emailId)
          .set({'read': !currentReadState}, SetOptions(merge: true));
      AppFunctions.debugPrint(
        'Đã cập nhật trạng thái read cho email $emailId: ${!currentReadState}',
      );
    } catch (e) {
      AppFunctions.debugPrint('Lỗi khi cập nhật trạng thái read: $e');
      rethrow;
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
          .set(emailState.copyWith(trashed: !emailState.trashed).toMap());

      final updatedStateDoc =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('email_states')
              .doc(emailId)
              .get();
      final updatedEmailState =
          updatedStateDoc.exists
              ? EmailState.fromMap(updatedStateDoc.data()!)
              : EmailState(emailId: emailId);
      AppFunctions.debugPrint(
        'Xác nhận trạng thái trashed sau khi cập nhật: ${updatedEmailState.trashed}',
      );
    } catch (e) {
      AppFunctions.debugPrint('Lỗi khi chuyển vào thùng rác: $e');
      throw Exception('Không thể chuyển vào thùng rác: $e');
    }
  }

  Future<int> countUnreadEmails() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Chưa đăng nhập để đếm email chưa đọc');
      }

      final snapshot =
          await _firestore
              .collection('users')
              .doc(user.uid)
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

  Future<void> markAsImportant(String emailId, bool currentStatus) async {
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
          .set(emailState.copyWith(important: !currentStatus).toMap());
      AppFunctions.debugPrint(
        'Đã cập nhật trạng thái quan trọng: ${!currentStatus}',
      );
    } catch (e) {
      AppFunctions.debugPrint('Lỗi khi đánh dấu đánh dấu email quan trọng: $e');
      throw Exception('Không thể đánh dấu email quan trọng: $e');
    }
  }

  Future<void> markAsSpam(String emailId, bool currentStatus) async {
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
          .set(emailState.copyWith(spam: !currentStatus).toMap());
      AppFunctions.debugPrint('Đã cập nhật trạng thái spam: ${!currentStatus}');
    } catch (e) {
      AppFunctions.debugPrint('Lỗi khi báo cáo spam: $e');
      throw Exception('Không thể báo cáo spam: $e');
    }
  }

  Future<void> markAsHidden(String emailId, bool currentStatus) async {
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
          .set(emailState.copyWith(hidden: !currentStatus).toMap());
      AppFunctions.debugPrint('Đã cập nhật trạng thái ẩn: ${!currentStatus}');
    } catch (e) {
      AppFunctions.debugPrint('Lỗi khi ẩn email: $e');
      throw Exception('Không thể ẩn email: $e');
    }
  }

  Future<void> updateEmailStatus(
    String emailId,
    Map<String, dynamic> updates,
  ) async {
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

      final updatedState = emailState.copyWith(
        read:
            updates['read'] is bool ? updates['read'] as bool : emailState.read,
        starred:
            updates['starred'] is bool
                ? updates['starred'] as bool
                : emailState.starred,
        trashed:
            updates['trashed'] is bool
                ? updates['trashed'] as bool
                : emailState.trashed,
        important:
            updates['important'] is bool
                ? updates['important'] as bool
                : emailState.important,
        spam:
            updates['spam'] is bool ? updates['spam'] as bool : emailState.spam,
        hidden:
            updates['hidden'] is bool
                ? updates['hidden'] as bool
                : emailState.hidden,
        labels:
            updates['labels'] is List<String>
                ? updates['labels'] as List<String>
                : emailState.labels,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('email_states')
          .doc(emailId)
          .set(updatedState.toMap());
      AppFunctions.debugPrint('Đã cập nhật trạng thái email: $updates');
    } catch (e) {
      AppFunctions.debugPrint('Lỗi khi cập nhật trạng thái email: $e');
      throw Exception('Không thể cập nhật trạng thái email: $e');
    }
  }
}
