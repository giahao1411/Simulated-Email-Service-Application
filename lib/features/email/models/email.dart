import 'package:cloud_firestore/cloud_firestore.dart';

class Email {
  Email({
    required this.id,
    required this.from,
    required this.to,
    required this.cc,
    required this.bcc,
    required this.subject,
    required this.body,
    required this.timestamp,
    this.read = false,
    this.starred = false,
    this.labels = const [],
  });

  factory Email.fromMap(String id, Map<String, dynamic> data) {
    return Email(
      id: id,
      from: data['from'] as String? ?? '',
      to: data['to'] as String? ?? '',
      cc: (data['cc'] as List<dynamic>? ?? []).cast<String>(),
      bcc: (data['bcc'] as List<dynamic>? ?? []).cast<String>(),
      subject: data['subject'] as String? ?? '',
      body: data['body'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      read: data['read'] as bool? ?? false,
      starred: data['starred'] as bool? ?? false,
      labels: (data['labels'] as List<dynamic>? ?? []).cast<String>(),
    );
  }

  final String id;
  final String from;
  final String to;
  final List<String> cc;
  final List<String> bcc;
  final String subject;
  final String body;
  final DateTime timestamp;
  final bool read;
  final bool starred;
  final List<String> labels;

  Map<String, dynamic> toMap() {
    return {
      'from': from,
      'to': to,
      'cc': cc,
      'bcc': bcc,
      'subject': subject,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'read': read,
      'starred': starred,
      'labels': labels,
    };
  }
}
