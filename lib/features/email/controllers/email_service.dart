import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/email.dart';

class EmailService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userPhone;

  EmailService() : userPhone = FirebaseAuth.instance.currentUser?.phoneNumber;

  Stream<List<Email>> getEmails(String category) {
    Query<Map<String, dynamic>> query = _firestore
        .collection('emails')
        .where('to', isEqualTo: userPhone)
        .orderBy('timestamp', descending: true);

    if (category == "Có gắn dấu sao") {
      query = query.where('starred', isEqualTo: true);
    } else if (category == "Đã gửi") {
      query = _firestore
          .collection('emails')
          .where('from', isEqualTo: userPhone)
          .orderBy('timestamp', descending: true);
    } else if (category == "Thư nháp") {
      query = _firestore
          .collection('drafts')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .orderBy('timestamp', descending: true);
    }

    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map((doc) => Email.fromMap(doc.id, doc.data()))
              .toList(),
    );
  }

  Future<void> sendEmail(String to, String subject, String body) async {
    await _firestore.collection('emails').add({
      'from': userPhone,
      'to': to,
      'subject': subject,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
      'starred': false,
      'labels': [],
    });
  }

  Future<void> saveDraft(String to, String subject, String body) async {
    await _firestore.collection('drafts').add({
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'to': to,
      'subject': subject,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggleStar(String emailId, bool currentStatus) async {
    await _firestore.collection('emails').doc(emailId).update({
      'starred': !currentStatus,
    });
  }

  Future<void> addLabel(String emailId, String label) async {
    await _firestore.collection('emails').doc(emailId).update({
      'labels': FieldValue.arrayUnion([label]),
    });
  }
}
