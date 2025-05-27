import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/core/constants/app_strings.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/models/email_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailService {
  EmailService() : userEmail = FirebaseAuth.instance.currentUser?.email;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userEmail;
  final Map<String, String> _fullNameCache = {};

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

          // Lấy họ tên người gửi
          final senderFullName = await getUserFullNameByEmail(email.from);

          if (emailState.hidden && category != AppStrings.hidden) {
            AppFunctions.debugPrint(
              'Bỏ qua email ẩn: ${email.id} cho danh mục $category',
            );
            continue;
          }

          if (emailState.trashed && category != AppStrings.trash) {
            AppFunctions.debugPrint(
              'Bỏ qua email trong thùng rác: ${email.id} cho danh mục $category',
            );
            continue;
          }

          // Lọc theo danh mục
          if (category == AppStrings.starred && !emailState.starred) continue;
          if (category == AppStrings.trash && !emailState.trashed) continue;
          if (category == AppStrings.important && !emailState.important)
            continue;
          if (category == AppStrings.spam && !emailState.spam) continue;
          if (category == AppStrings.hidden && !emailState.hidden) continue;
          if (category != AppStrings.starred &&
              category != AppStrings.trash &&
              category != AppStrings.inbox &&
              category != AppStrings.sent &&
              category != AppStrings.drafts &&
              category != AppStrings.important &&
              category != AppStrings.spam &&
              category != AppStrings.hidden &&
              !emailState.labels.contains(category)) {
            continue;
          }

          emailsWithState.add({
            'email': email,
            'state': emailState,
            'senderFullName': senderFullName, // Thêm họ tên vào dữ liệu trả về
          });
        }
        if (emailsWithState.isEmpty) {
          AppFunctions.debugPrint(
            'Danh sách email rỗng cho danh mục: $category',
          );
        }
        return emailsWithState;
      } on Exception catch (e) {
        AppFunctions.debugPrint('Lỗi khi ánh xạ dữ liệu email: $e');
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

                // Lấy họ tên người gửi
                final senderFullName = await getUserFullNameByEmail(email.from);

                // Loại bỏ email ẩn hoặc trong thùng rác khỏi hộp thư đến
                if (emailState.hidden || emailState.trashed) {
                  AppFunctions.debugPrint(
                    'Bỏ qua email ${email.id} (ẩn hoặc trong thùng rác) cho hộp thư đến',
                  );
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

              // Lấy họ tên người gửi
              final senderFullName = await getUserFullNameByEmail(email.from);

              // Loại bỏ email ẩn hoặc trong thùng rác khỏi hộp thư đến
              if (emailState.hidden || emailState.trashed) {
                AppFunctions.debugPrint(
                  'Bỏ qua email ${email.id} (ẩn hoặc trong thùng rác) cho hộp thư đến',
                );
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
      AppFunctions.debugPrint('Lỗi khi đánh dấu quan trọng: $e');
      throw Exception('Không thể đánh dấu quan trọng: $e');
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
      AppFunctions.debugPrint('Lỗi khi báo cáo thư rác: $e');
      throw Exception('Không thể báo cáo thư rác: $e');
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
      AppFunctions.debugPrint('Lỗi khi tạm ẩn: $e');
      throw Exception('Không thể tạm ẩn: $e');
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
