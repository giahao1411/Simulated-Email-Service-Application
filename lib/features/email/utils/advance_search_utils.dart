import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_application/core/constants/app_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdvanceSearchUtils {
  static Future<Map<String, List<String>>> fetchEmailContacts() async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail == null) {
      AppFunctions.debugPrint('Không thể lấy email người dùng');
      return {'senders': [], 'recipients': []};
    }

    try {
      final emailsSnapshot =
          await FirebaseFirestore.instance
              .collection('emails')
              .where(
                Filter.or(
                  Filter('from', isEqualTo: userEmail),
                  Filter('to', arrayContains: userEmail),
                  Filter('cc', arrayContains: userEmail),
                  Filter('bcc', arrayContains: userEmail),
                ),
              )
              .orderBy('timestamp', descending: true)
              .limit(200)
              .get();

      final senders = <String>{};
      final recipients = <String>{};

      for (final doc in emailsSnapshot.docs) {
        final data = doc.data();
        final from = data['from'] as String?;
        final toList =
            data['to'] is Iterable
                ? List<String>.from(data['to'] as Iterable)
                : <String>[];
        final ccList =
            data['cc'] is Iterable
                ? List<String>.from(data['cc'] as Iterable)
                : <String>[];
        final bccList =
            data['bcc'] is Iterable
                ? List<String>.from(data['bcc'] as Iterable)
                : <String>[];

        if (from == userEmail) {
          recipients
            ..addAll(toList.where((e) => e != userEmail))
            ..addAll(ccList.where((e) => e != userEmail))
            ..addAll(bccList.where((e) => e != userEmail));
        } else {
          if (from != null && from != userEmail) {
            senders.add(from);
          }
          final userIsRecipient =
              toList.contains(userEmail) ||
              ccList.contains(userEmail) ||
              bccList.contains(userEmail);
          if (userIsRecipient && from != null && from != userEmail) {
            senders.add(from);
          }
        }
      }

      final sortedSenders = senders.toList()..sort();
      final sortedRecipients = recipients.toList()..sort();

      AppFunctions.debugPrint('Fetched senders: $sortedSenders');
      AppFunctions.debugPrint('Fetched recipients: $sortedRecipients');

      return {'senders': sortedSenders, 'recipients': sortedRecipients};
    } on Exception catch (e) {
      AppFunctions.debugPrint('Lỗi khi lấy danh sách email: $e');
      return {'senders': [], 'recipients': []};
    }
  }

  static String formatDateRange(DateTimeRange dateRange) {
    final vietnameseMonths = <String>[
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
    ];
    final start = dateRange.start;
    final end = dateRange.end;
    final startMonth = vietnameseMonths[start.month - 1];
    final endMonth = vietnameseMonths[end.month - 1];
    return '${start.day} $startMonth ${start.year} - ${end.day} $endMonth ${end.year}';
  }

  static String getCategoryDisplayName(String category) {
    const categoryNames = <String, String>{
      'Inbox': 'Hộp thư đến',
      'Sent': 'Đã gửi',
      'Drafts': 'Thư nháp',
      'Important': 'Quan trọng',
      'Spam': 'Thư rác',
      'Trash': 'Thùng rác',
      'Starred': 'Đã đánh dấu',
    };
    return categoryNames[category] ?? category;
  }
}
