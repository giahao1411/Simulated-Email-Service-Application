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
    this.read = false,
    this.starred = false,
    this.labels = const [],
    this.isDraft = false,
    this.hasAttachments = false,
    this.hidden = false,
    this.important = false,
    this.spam = false,
    this.trashed = false, // Thêm trường trashed
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
      read: data['read'] as bool? ?? false,
      starred: data['starred'] as bool? ?? false,
      labels: (data['labels'] as List<dynamic>? ?? []).cast<String>(),
      isDraft: data['isDraft'] as bool? ?? false,
      hasAttachments: data['hasAttachments'] as bool? ?? false,
      hidden: data['hidden'] as bool? ?? false,
      important: data['important'] as bool? ?? false,
      spam: data['spam'] as bool? ?? false,
      trashed:
          data['trashed'] as bool? ?? false, // Thêm deserialization cho trashed
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
  final bool read;
  final bool starred;
  final List<String> labels;
  final bool isDraft;
  final bool hasAttachments;
  final bool hidden;
  final bool important;
  final bool spam;
  final bool trashed; // Thêm trường trashed

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
      'isDraft': isDraft,
      'hasAttachments': hasAttachments,
      'hidden': hidden,
      'important': important,
      'spam': spam,
      'trashed': trashed, // Thêm serialization cho trashed
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
    bool? read,
    bool? starred,
    List<String>? labels,
    bool? isDraft,
    bool? hasAttachments,
    bool? hidden,
    bool? important,
    bool? spam,
    bool? trashed,
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
      read: read ?? this.read,
      starred: starred ?? this.starred,
      labels: labels ?? this.labels,
      isDraft: isDraft ?? this.isDraft,
      hasAttachments: hasAttachments ?? this.hasAttachments,
      hidden: hidden ?? this.hidden,
      important: important ?? this.important,
      spam: spam ?? this.spam,
      trashed: trashed ?? this.trashed, // Thêm trong copyWith
    );
  }
}
