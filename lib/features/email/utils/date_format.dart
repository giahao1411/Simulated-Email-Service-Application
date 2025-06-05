class DateFormat {
  static const List<String> months = [
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

  static String formatTimestamp(DateTime timestamp, {bool fullFormat = false}) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 5) {
      return 'Vừa xong';
    } else if (difference.inHours < 24 && now.day == timestamp.day) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (fullFormat) {
      return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year} lúc ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (timestamp.year == now.year) {
      return '${timestamp.day} ${months[timestamp.month - 1]}';
    } else {
      return '${timestamp.day}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year}';
    }
  }

  static String formatDetailedTimestamp(DateTime timestamp) {
    return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year} lúc ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  // Hàm mới để chuyển đổi từ các định dạng khác nhau về DateTime
  static DateTime? parseFromString(String dateString) {
    try {
      // Định dạng 1: "DD/MM/YYYY lúc HH:mm"
      final dateRegExp1 = RegExp(
        r'(\d{2})/(\d{2})/(\d{4})\s+lúc\s+(\d{2}):(\d{2})',
      );
      final match1 = dateRegExp1.firstMatch(dateString);
      if (match1 != null) {
        return DateTime(
          int.parse(match1.group(3)!), // Year
          int.parse(match1.group(2)!), // Month
          int.parse(match1.group(1)!), // Day
          int.parse(match1.group(4)!), // Hour
          int.parse(match1.group(5)!), // Minute
        );
      }

      // Định dạng 2: "YYYY-MM-DD HH:mm:ss.SSS"
      final dateRegExp2 = RegExp(
        r'(\d{4})-(\d{2})-(\d{2})\s+(\d{2}):(\d{2}):(\d{2})\.(\d{3})',
      );
      final match2 = dateRegExp2.firstMatch(dateString);
      if (match2 != null) {
        return DateTime(
          int.parse(match2.group(1)!), // Year
          int.parse(match2.group(2)!), // Month
          int.parse(match2.group(3)!), // Day
          int.parse(match2.group(4)!), // Hour
          int.parse(match2.group(5)!), // Minute
          int.parse(match2.group(6)!), // Second
          int.parse(match2.group(7)!), // Millisecond
        );
      }

      // Định dạng 3: Standard ISO format
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Hàm để format lại text có chứa thời gian
  static String formatTextWithTimestamp(String text) {
    // Định dạng 1: "Vào DD/MM/YYYY lúc HH:mm"
    text = text.replaceAllMapped(
      RegExp(r'Vào\s+(\d{2}/\d{2}/\d{4}\s+lúc\s+\d{2}:\d{2})'),
      (match) {
        final dateStr = match.group(1)!;
        final parsedDate = parseFromString(dateStr);
        if (parsedDate != null) {
          return formatDetailedTimestamp(
            parsedDate,
          ); // Bỏ "Vào", chỉ giữ ngày tháng
        }
        return match.group(0)!;
      },
    );

    // Định dạng 2: "On YYYY-MM-DD HH:mm:ss.SSS"
    text = text.replaceAllMapped(
      RegExp(r'On\s+(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}\.\d{3})'),
      (match) {
        final dateStr = match.group(1)!;
        final parsedDate = parseFromString(dateStr);
        if (parsedDate != null) {
          return formatDetailedTimestamp(parsedDate);
        }
        return match.group(0)!;
      },
    );

    // Định dạng 3: Subject line "DD/MM/YYYY lúc HH:mm"
    text = text.replaceAllMapped(
      RegExp(r'(\d{2}/\d{2}/\d{4}\s+lúc\s+\d{2}:\d{2})'),
      (match) {
        final dateStr = match.group(1)!;
        final parsedDate = parseFromString(dateStr);
        if (parsedDate != null) {
          return formatDetailedTimestamp(parsedDate);
        }
        return match.group(0)!;
      },
    );

    return text;
  }
}
