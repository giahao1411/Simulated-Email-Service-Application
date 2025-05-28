import 'package:cloud_firestore/cloud_firestore.dart';

class Email {
  Email({
    required this.id,
    required this.from,
    required this.to,
    required this.subject,
    required this.body,
    required this.timestamp,
    this.cc = const [],
    this.bcc = const [],
    this.isDraft = false,
    this.hasAttachments = false,
    this.userId, // Thêm trường userId
  });

  factory Email.fromMap(String id, Map<String, dynamic> data) {
    return Email(
      id: id,
      from: data['from'] as String? ?? '',
      to: (data['to'] as List<dynamic>? ?? []).cast<String>(),
      cc: (data['cc'] as List<dynamic>? ?? []).cast<String>(),
      bcc: (data['bcc'] as List<dynamic>? ?? []).cast<String>(),
      subject: data['subject'] as String? ?? '',
      body: data['body'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isDraft: data['isDraft'] as bool? ?? false,
      hasAttachments: data['hasAttachments'] as bool? ?? false,
      userId: data['userId'] as String?, // Ánh xạ userId từ Firestore
    );
  }

  final String id;
  final String from;
  final List<String> to;
  final List<String> cc;
  final List<String> bcc;
  final String subject;
  final String body;
  final DateTime timestamp;
  final bool isDraft;
  final bool hasAttachments;
  final String? userId; // Có thể null cho email không phải nháp

  Map<String, dynamic> toMap() {
    return {
      'from': from,
      'to': to,
      'cc': cc,
      'bcc': bcc,
      'subject': subject,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'isDraft': isDraft,
      'hasAttachments': hasAttachments,
      'userId': userId, // Lưu userId vào Firestore
    };
  }

  Email copyWith({
    String? id,
    String? from,
    List<String>? to,
    List<String>? cc,
    List<String>? bcc,
    String? subject,
    String? body,
    DateTime? timestamp,
    bool? isDraft,
    bool? hasAttachments,
    String? userId,
  }) {
    return Email(
      id: id ?? this.id,
      from: from ?? this.from,
      to: to ?? this.to,
      cc: cc ?? this.cc,
      bcc: bcc ?? this.bcc,
      subject: subject ?? this.subject,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      isDraft: isDraft ?? this.isDraft,
      hasAttachments: hasAttachments ?? this.hasAttachments,
      userId: userId ?? this.userId,
    );
  }
}
