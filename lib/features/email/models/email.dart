import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_application/features/email/utils/datetime_utils.dart';

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
    this.inReplyTo,
    this.userId, // Thêm trường userId
    this.isReplied = false,
    this.replyEmailIds = const [],
    this.attachments = const [], // Thêm trường attachments
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
      timestamp: parseToDateTime(data['timestamp']),
      isDraft: data['isDraft'] as bool? ?? false,
      hasAttachments: data['hasAttachments'] as bool? ?? false,
      inReplyTo: data['inReplyTo'] as String?,
      userId: data['userId'] as String?, // Ánh xạ userId từ Firestore
      isReplied: data['isReplied'] as bool? ?? false,
      replyEmailIds:
          (data['replyEmailIds'] as List<dynamic>? ?? []).cast<String>(),
      attachments:
          (data['attachments'] as List<dynamic>? ?? [])
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList(), // Ánh xạ danh sách attachments
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
  final String? inReplyTo;
  final String? userId; // Có thể null cho email không phải nháp
  final bool isReplied;
  final List<String> replyEmailIds;
  final List<Map<String, dynamic>> attachments; // Danh sách file đính kèm

  Map<String, dynamic> toMap() {
    return {
      'from': from,
      'to': to,
      'cc': cc,
      'bcc': bcc,
      'subject': subject,
      'body': body,
      'timestamp': Timestamp.fromDate(timestamp),
      'isDraft': isDraft,
      'hasAttachments': hasAttachments,
      'inReplyTo': inReplyTo,
      'userId': userId, // Lưu userId vào Firestore
      'isReplied': isReplied,
      'replyEmailIds': replyEmailIds,
      'attachments': attachments, // Lưu danh sách attachments
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
    String? inReplyTo,
    String? userId,
    bool? isReplied,
    List<String>? replyEmailIds,
    List<Map<String, dynamic>>? attachments,
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
      inReplyTo: inReplyTo ?? this.inReplyTo,
      userId: userId ?? this.userId,
      isReplied: isReplied ?? this.isReplied,
      replyEmailIds: replyEmailIds ?? this.replyEmailIds,
      attachments: attachments ?? this.attachments,
    );
  }
}
