import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailService {
  EmailService() : userEmail = FirebaseAuth.instance.currentUser?.email;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userEmail;

  Stream<List<Email>> getEmails(String category) {
    // Kiểm tra nếu người dùng chưa đăng nhập
    if (userEmail == null || FirebaseAuth.instance.currentUser == null) {
      print('Không truy vấn email vì chưa đăng nhập');
      return Stream.value([]);
    }

    print('Lấy email cho danh mục: $category');
    var query = _firestore
        .collection('emails')
        .where('to', arrayContains: userEmail)
        .orderBy('timestamp', descending: true);

    if (category == 'Có gắn dấu sao') {
      query = query.where('starred', isEqualTo: true);
    } else if (category == 'Đã gửi') {
      query = _firestore
          .collection('emails')
          .where('from', isEqualTo: userEmail)
          .orderBy('timestamp', descending: true);
    } else if (category == 'Thư nháp') {
      query = _firestore
          .collection('drafts')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .orderBy('timestamp', descending: true);
    }

    return Stream.fromFuture(
      query
          .get()
          .then((snapshot) {
            try {
              return snapshot.docs
                  .map((doc) => Email.fromMap(doc.id, doc.data()))
                  .toList();
            } on Exception catch (e) {
              print('Lỗi khi ánh xạ dữ liệu email: $e');
              return <Email>[];
            }
          })
          .catchError((e) {
            print('Lỗi khi truy vấn Firestore: $e');
            return <Email>[];
          }),
    );
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
        'labels': <String>[],
      });
    } on Exception catch (e) {
      print('Lỗi khi gửi email: $e');
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
      print('Lỗi khi lưu thư nháp: $e');
      throw Exception('Lỗi khi lưu thư nháp: $e');
    }
  }

  Future<void> toggleStar(String emailId, bool currentStatus) async {
    try {
      await _firestore.collection('emails').doc(emailId).update({
        'starred': !currentStatus,
      });
    } catch (e) {
      print('Lỗi khi thay đổi trạng thái sao: $e');
      throw Exception('Không thể thay đổi trạng thái sao: $e');
    }
  }

  Future<void> toggleRead(String emailId, bool currentStatus) async {
    try {
      await _firestore.collection('emails').doc(emailId).update({
        'read': !currentStatus,
      });
    } catch (e) {
      print('Lỗi khi thay đổi trạng thái đã đọc: $e');
      throw Exception('Không thể thay đổi trạng thái đã đọc: $e');
    }
  }

  Future<void> addLabel(String emailId, String label) async {
    try {
      await _firestore.collection('emails').doc(emailId).update({
        'labels': FieldValue.arrayUnion([label]),
      });
    } catch (e) {
      print('Lỗi khi thêm nhãn: $e');
      throw Exception('Không thể thêm nhãn: $e');
    }
  }
}
