import 'package:email_application/features/email/models/email.dart';
import 'package:flutter/material.dart';

class EmailSearchResult {
  final String senderName;
  final String subject;
  final String preview;
  final String time;
  final String? avatarUrl;
  final String? avatarText;
  final Color? backgroundColor;
  final bool isStarred;
  final bool isImportant;
  final Email? email;

  EmailSearchResult({
    required this.senderName,
    required this.subject,
    required this.preview,
    required this.time,
    this.avatarUrl,
    this.avatarText,
    this.backgroundColor,
    this.isStarred = false,
    this.isImportant = false,
    this.email,
  });

  factory EmailSearchResult.fromJson(Map<String, dynamic> json) {
    return EmailSearchResult(
      senderName: json['senderName']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      preview: json['preview']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
      avatarText: json['avatarText']?.toString(),
      backgroundColor:
          json['backgroundColor'] != null
              ? Color(json['backgroundColor'] as int)
              : null,
      isStarred: json['isStarred'] as bool? ?? false,
      isImportant: json['isImportant'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderName': senderName,
      'subject': subject,
      'preview': preview,
      'time': time,
      'avatarUrl': avatarUrl,
      'avatarText': avatarText,
      'backgroundColor': backgroundColor?.value,
      'isStarred': isStarred,
      'isImportant': isImportant,
    };
  }
}
