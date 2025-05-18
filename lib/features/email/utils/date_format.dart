class DateFormat {
  static String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    if (difference.inMinutes < 5) {
      return 'Vừa xong';
    } else if (difference.inHours < 24 && now.day == timestamp.day) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (timestamp.year == now.year) {
      return '${timestamp.day} ${months[timestamp.month - 1]}';
    } else {
      return '${timestamp.day}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year}';
    }
  }
}
