import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/core/constants/app_strings.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailService {
  EmailService() : userEmail = FirebaseAuth.instance.currentUser?.email;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userEmail;

  Stream<List<Email>> getEmails(String category) {
    if (userEmail == null || FirebaseAuth.instance.currentUser == null) {
      AppFunctions.debugPrint('Không truy vấn email vì chưa đăng nhập');
      return Stream.value([]);
    }

    AppFunctions.debugPrint('Lấy email cho danh mục: $category');
    var query = _firestore
        .collection(category == 'Thư nháp' ? 'drafts' : 'emails')
        .orderBy('timestamp', descending: true)
        .limit(50);

    if (category == AppStrings.inbox) {
      query = query.where('to', arrayContains: userEmail);
    } else if (category == AppStrings.starred) {
      query = query
          .where('to', arrayContains: userEmail)
          .where('starred', isEqualTo: true);
    } else if (category == AppStrings.sent) {
      query = query.where('from', isEqualTo: userEmail);
    } else if (category == AppStrings.drafts) {
      query = query.where(
        'userId',
        isEqualTo: FirebaseAuth.instance.currentUser?.uid,
      );
    } else if (category == AppStrings.trash) {
      query = query
          .where('to', arrayContains: userEmail)
          .where('trashed', isEqualTo: true);
    } else if (category == AppStrings.spam) {
      query = query
          .where('to', arrayContains: userEmail)
          .where('spam', isEqualTo: true);
    } else if (category == AppStrings.important) {
      query = query
          .where('to', arrayContains: userEmail)
          .where('important', isEqualTo: true);
    } else if (category == AppStrings.hidden) {
      query = query
          .where('to', arrayContains: userEmail)
          .where('hidden', isEqualTo: true);
    } else {
      query = query.where('labels', arrayContains: category);
    }

    return query.snapshots().map((snapshot) {
      try {
        return snapshot.docs
            .map((doc) => Email.fromMap(doc.id, doc.data()))
            .toList();
      } on Exception catch (e) {
        AppFunctions.debugPrint('Lỗi khi ánh xạ dữ liệu email: $e');
        return <Email>[];
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

      await _firestore.collection('emails').add({
        'from': userEmail,
        'to': to,
        'cc': cc,
        'bcc': bcc,
        'subject': subject,
        'body': body,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'starred': false,
        'important': false,
        'hidden': false,
        'spam': false,
        'labels': <String>[],
      });
    } on Exception catch (e) {
      AppFunctions.debugPrint('Lỗi khi gửi email: $e');
      throw Exception('Lỗi khi gửi email: $e');
    }
  }

  Future<void> saveDraft(String to, String subject, String body) async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        throw Exception('Chưa đăng nhập để lưu thư nháp');
      }
      await _firestore.collection('drafts').add({
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'to': to,
        'subject': subject,
        'body': body,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } on Exception catch (e) {
      AppFunctions.debugPrint('Lỗi khi lưu thư nháp: $e');
      throw Exception('Lỗi khi lưu thư nháp: $e');
    }
  }

  Future<void> toggleStar(String emailId, bool currentStatus) async {
    try {
      await _firestore.collection('emails').doc(emailId).update({
        'starred': !currentStatus,
      });
    } catch (e) {
      AppFunctions.debugPrint('Lỗi khi thay đổi trạng thái sao: $e');
      throw Exception('Không thể thay đổi trạng thái sao: $e');
    }
  }

  Future<void> toggleRead(String emailId, bool currentStatus) async {
    try {
      await _firestore.collection('emails').doc(emailId).update({
        'read': !currentStatus,
      });
    } catch (e) {
      AppFunctions.debugPrint('Lỗi khi thay đổi trạng thái đã đọc: $e');
      throw Exception('Không thể thay đổi trạng thái đã đọc: $e');
    }
  }

  Future<void> addLabel(String emailId, String label) async {
    try {
      await _firestore.collection('emails').doc(emailId).update({
        'labels': FieldValue.arrayUnion([label]),
      });
    } catch (e) {
      AppFunctions.debugPrint('Lỗi khi thêm nhãn: $e');
      throw Exception('Không thể thêm nhãn: $e');
    }
  }

  Future<int> countUnreadEmails() async {
    try {
      final snapshot =
          await _firestore
              .collection('emails')
              .where('to', arrayContains: userEmail)
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

  Future<void> deleteEmail(String emailId) async {
    try {
      await _firestore.collection('emails').doc(emailId).delete();
    } catch (e) {
      AppFunctions.debugPrint('Lỗi khi xóa email: $e');
      throw Exception('Không thể xóa email: $e');
    }
  }

  Future<void> markAsImportant(String emailId, bool currentStatus) async {
    try {
      await _firestore.collection('emails').doc(emailId).update({
        'important': !currentStatus,
      });
    } catch (e) {
      AppFunctions.debugPrint('Lỗi khi đánh dấu quan trọng: $e');
      throw Exception('Không thể đánh dấu quan trọng: $e');
    }
  }

  Future<void> markAsSpam(String emailId, bool currentStatus) async {
    try {
      await _firestore.collection('emails').doc(emailId).update({
        'spam': !currentStatus,
      });
    } catch (e) {
      AppFunctions.debugPrint('Lỗi khi báo cáo thư rác: $e');
      throw Exception('Không thể báo cáo thư rác: $e');
    }
  }

  Future<void> markAsHidden(String emailId, bool currentStatus) async {
    try {
      await _firestore.collection('emails').doc(emailId).update({
        'hidden': !currentStatus,
      });
    } catch (e) {
      AppFunctions.debugPrint('Lỗi khi tạm ẩn: $e');
      throw Exception('Không thể tạm ẩn: $e');
    }
  }

  // Thêm phương thức updateEmailStatus để cập nhật nhiều trường cùng lúc
  Future<void> updateEmailStatus(
    String emailId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore.collection('emails').doc(emailId).update(updates);
      AppFunctions.debugPrint('Đã cập nhật trạng thái email: $updates');
    } catch (e) {
      AppFunctions.debugPrint('Lỗi khi cập nhật trạng thái email: $e');
      throw Exception('Không thể cập nhật trạng thái email: $e');
    }
  }
}
