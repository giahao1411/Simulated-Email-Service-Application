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
}
