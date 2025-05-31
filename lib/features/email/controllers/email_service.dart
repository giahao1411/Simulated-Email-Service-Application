import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/core/constants/app_strings.dart';
import 'package:email_application/features/email/models/draft.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/models/email_state.dart';
import 'package:email_application/features/email/utils/email_reply.dart';
import 'package:email_application/features/email/utils/email_service_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailService {
  EmailService() : userEmail = FirebaseAuth.instance.currentUser?.email;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userEmail;

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

    final emailStream =
        category != null && category.isNotEmpty
            ? getEmails(category)
            : getAllEmails();

    return emailStream.asyncMap((allEmails) async {
      final filteredEmails = <Map<String, dynamic>>[];

      for (final emailData in allEmails) {
        final email = emailData['email'] as Email;
        final emailState = emailData['state'] as EmailState;
        var shouldInclude = true;

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
          shouldInclude = EmailServiceUtils.emailMatchesCategory(
            email,
            emailState,
            category,
          );
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

  Stream<List<Map<String, dynamic>>> getEmails(String category) {
    if (userEmail == null || FirebaseAuth.instance.currentUser == null) {
      AppFunctions.debugPrint('Không truy vấn email vì chưa đăng nhập');
      return Stream.value([]);
    }

    AppFunctions.debugPrint('Lấy email cho danh mục: $category');

    if (category == AppStrings.inbox) {
      return EmailServiceUtils.getInboxEmails();
    }

    final isDraft = category == AppStrings.drafts;
    var query = _firestore
        .collection(isDraft ? 'drafts' : 'emails')
        .orderBy('timestamp', descending: true);

    if (category == AppStrings.sent) {
      query = query.where('from', isEqualTo: userEmail);
    } else if (isDraft) {
      query = query.where(
        'userId',
        isEqualTo: FirebaseAuth.instance.currentUser!.uid,
      );
    } else if (category == AppStrings.starred) {}

    return query.snapshots().asyncMap((snapshot) async {
      try {
        final emailsWithState = <Map<String, dynamic>>[];
        for (final doc in snapshot.docs) {
          final data = doc.data();
          if (data.isEmpty) {
            AppFunctions.debugPrint('Bỏ qua tài liệu rỗng: ${doc.id}');
            continue;
          }

          try {
            // initiate email object based on type
            final email =
                isDraft
                    ? Draft.fromMap(doc.id, data)
                    : Email.fromMap(doc.id, data);

            var emailState = EmailState(emailId: doc.id);
            if (!isDraft) {
              final stateDoc =
                  await _firestore
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('email_states')
                      .doc(doc.id)
                      .get();
              emailState =
                  stateDoc.exists
                      ? EmailState.fromMap(stateDoc.data()!)
                      : EmailState(emailId: doc.id);
            }

            // Lấy tên người gửi
            final senderFullName =
                await EmailServiceUtils.getUserFullNameByEmail(
                  isDraft ? (email as Draft).userId : (email as Email).from,
                );

            // Kiểm tra xem email có thuộc danh mục không
            if (!EmailServiceUtils.emailMatchesCategory(
              email,
              emailState,
              category,
            )) {
              AppFunctions.debugPrint(
                'Bỏ qua email ${doc.id} vì không thuộc danh mục: $category',
              );
              continue;
            }

            emailsWithState.add({
              'email': email,
              'state': emailState,
              'senderFullName': senderFullName,
            });
          } on Exception catch (e) {
            AppFunctions.debugPrint('Lỗi khi xử lý email ${doc.id}: $e');
            continue;
          }
        }

        if (emailsWithState.isEmpty) {
          AppFunctions.debugPrint(
            'Danh sách email rỗng cho danh mục: $category',
          );
        } else {
          AppFunctions.debugPrint(
            'Tìm thấy ${emailsWithState.length} email trong danh mục "$category"',
          );
        }
        return emailsWithState;
      } on Exception catch (e) {
        AppFunctions.debugPrint('Lỗi khi ánh xạ dữ liệu email: $e');
        return [];
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

          final senderFullName = await EmailServiceUtils.getUserFullNameByEmail(
            email.from,
          );

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
          .set(EmailState(emailId: emailRef.id, read: true).toMap());

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
          await EmailServiceUtils.updateUserContacts(
            userId: recipientUid,
            from: userEmail!,
            to: to,
            cc: cc,
            bcc: bcc,
          );
        }
      }

      // Cập nhật danh bạ cho người gửi
      await EmailServiceUtils.updateUserContacts(
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

  Future<void> sendReply(
    String emailId,
    EmailState state,
    String replyBody, {
    List<String> ccEmails = const [],
    List<String> bccEmails = const [],
    VoidCallback? onRefresh,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Người dùng chưa đăng nhập');

    AppFunctions.debugPrint('Sending reply for emailId: $emailId');

    final emailDoc = await _firestore.collection('emails').doc(emailId).get();
    if (!emailDoc.exists) throw Exception('Email không tồn tại');
    final originalEmail = Email.fromMap(emailId, emailDoc.data()!);

    final replyEmail = EmailReply.createCustomReply(
      originalEmail,
      user.email!,
      replyBody,
      ccEmails: ccEmails,
      bccEmails: bccEmails,
    );

    final replyDocRef = await _firestore
        .collection('emails')
        .add(replyEmail.toMap());
    final replyEmailId = replyDocRef.id;
    AppFunctions.debugPrint('Reply created with id: $replyEmailId');

    try {
      await _firestore.collection('emails').doc(emailId).update({
        'isReplied': true,
        'replyEmailIds': FieldValue.arrayUnion([replyEmailId]),
      });
      AppFunctions.debugPrint(
        'Updated original email with replyEmailId: $replyEmailId',
      );
    } catch (error) {
      AppFunctions.debugPrint('Error updating original email: $error');
      throw Exception('Failed to update original email: $error');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('email_states')
        .doc(replyEmailId)
        .set(
          EmailState(
            emailId: replyEmailId,
            read: true,
            labels: ['sent'],
          ).toMap(),
        );

    final allRecipients =
        <String>{
          originalEmail.from,
          ...ccEmails,
          ...bccEmails,
        }.where((email) => email != user.email).toList();
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
            .doc(replyEmailId)
            .set(EmailState(emailId: replyEmailId, labels: []).toMap());
        AppFunctions.debugPrint('Created EmailState for $recipientEmail');
      }
    }

    onRefresh?.call();
  }

  Future<void> sendForward(
    String emailId,
    String forwardBody,
    List<String> toEmails, {
    List<String> ccEmails = const [],
    List<String> bccEmails = const [],
    VoidCallback? onRefresh,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Người dùng chưa đăng nhập');

    AppFunctions.debugPrint('Sending forward for emailId: $emailId');

    final emailDoc = await _firestore.collection('emails').doc(emailId).get();
    if (!emailDoc.exists) throw Exception('Email không tồn tại');
    final originalEmail = Email.fromMap(emailId, emailDoc.data()!);

    final forwardEmail = Email(
      id: '',
      from: user.email!,
      to: toEmails,
      cc: ccEmails,
      bcc: bccEmails,
      subject: 'Fwd: ${originalEmail.subject}',
      body: forwardBody,
      timestamp: DateTime.now(),
      hasAttachments: originalEmail.hasAttachments,
      userId: user.uid,
    );

    try {
      final forwardDocRef = await _firestore
          .collection('emails')
          .add(forwardEmail.toMap());
      final forwardEmailId = forwardDocRef.id;
      AppFunctions.debugPrint('Forward created with id: $forwardEmailId');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('email_states')
          .doc(forwardEmailId)
          .set(
            EmailState(
              emailId: forwardEmailId,
              read: true,
              labels: ['sent'],
            ).toMap(),
          );

      final allRecipients =
          <String>{
            ...toEmails,
            ...ccEmails,
            ...bccEmails,
          }.where((email) => email != user.email).toList();
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
              .doc(forwardEmailId)
              .set(EmailState(emailId: forwardEmailId, labels: []).toMap());
          AppFunctions.debugPrint('Created EmailState for $recipientEmail');
        }
      }

      onRefresh?.call();
    } catch (error) {
      AppFunctions.debugPrint('Error sending forward: $error');
      throw Exception('Failed to send forward: $error');
    }
  }
}
