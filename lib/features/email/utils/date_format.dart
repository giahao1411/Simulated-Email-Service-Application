class DateFormat {
  static const List<String> months = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
  ];

  static String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 5) {
      return 'Vừa xong';
    } else if (difference.inHours < 24 && now.day == timestamp.day) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (timestamp.year == now.year) {
      return '${timestamp.day} thg ${months[timestamp.month - 1]}';
    } else {
      return '${timestamp.day}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year}';
    }
  }

  static String formatDetailedTimestamp(DateTime timestamp) {
    final day = timestamp.day;
    final month = months[timestamp.month - 1];
    final year = timestamp.year;
    final hour = timestamp.hour.toString().padLeft(2, '0'); // add 0 before hour
    final minute = timestamp.minute.toString().padLeft(
      2,
      '0',
    ); // add 0 before minute

    // return format example "1 May 2025 at 14:30"
    return '$day/$month/$year vào $hour:$minute';
  }
}
