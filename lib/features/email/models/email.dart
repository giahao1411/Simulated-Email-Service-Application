import 'package:cloud_firestore/cloud_firestore.dart';

class Email {
  final String id;
  final String from;
  final String to;
  final String subject;
  final String body;
  final DateTime timestamp;
  final bool read;
  final bool starred;
  final List<String> labels;

  Email({
    required this.id,
    required this.from,
    required this.to,
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
      from: data['from'] ?? '',
      to: data['to'] ?? '',
      subject: data['subject'] ?? '',
      body: data['body'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      read: data['read'] ?? false,
      starred: data['starred'] ?? false,
      labels: List<String>.from(data['labels'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'from': from,
      'to': to,
      'subject': subject,
      'body': body,
      'timestamp': timestamp,
      'read': read,
      'starred': starred,
      'labels': labels,
    };
  }
}
