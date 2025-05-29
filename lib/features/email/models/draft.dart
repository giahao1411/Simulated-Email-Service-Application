import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_application/features/email/utils/datetime_utils.dart';

class Draft {
  Draft({
    required this.id,
    required this.userId,
    required this.to,
    required this.subject,
    required this.body,
    required this.timestamp,
    this.cc = const [],
    this.bcc = const [],
  });

  factory Draft.fromMap(String id, Map<String, dynamic> data) {
    return Draft(
      id: id,
      userId: data['userId'] as String? ?? '',
      to: (data['to'] as List<dynamic>? ?? []).cast<String>(),
      cc: (data['cc'] as List<dynamic>? ?? []).cast<String>(),
      bcc: (data['bcc'] as List<dynamic>? ?? []).cast<String>(),
      subject: data['subject'] as String? ?? '',
      body: data['body'] as String? ?? '',
      timestamp: parseToDateTime(data['timestamp']),
    );
  }

  final String id;
  final String userId;
  final List<String> to;
  final List<String> cc;
  final List<String> bcc;
  final String subject;
  final String body;
  final DateTime timestamp;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'to': to,
      'cc': cc,
      'bcc': bcc,
      'subject': subject,
      'body': body,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  Draft copyWith({
    String? id,
    String? userId,
    List<String>? to,
    List<String>? cc,
    List<String>? bcc,
    String? subject,
    String? body,
    DateTime? timestamp,
  }) {
    return Draft(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      to: to ?? this.to,
      cc: cc ?? this.cc,
      bcc: bcc ?? this.bcc,
      subject: subject ?? this.subject,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
