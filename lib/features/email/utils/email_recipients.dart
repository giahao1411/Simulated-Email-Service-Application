class EmailRecipient {
  static String formatRecipient(
    List<String> to,
    List<String>? bcc,
    String currentUserEmail,
  ) {
    // 'to' list handle
    String toText;
    if (to.length == 1 && to.first == currentUserEmail) {
      toText = 'me';
    } else {
      toText = to.join(', ');
    }

    // 'bcc' list handle
    String bccText;
    if (bcc?.length == 1 && bcc?.first == currentUserEmail) {
      bccText = 'me';
    } else {
      bccText = bcc?.join(', ') ?? 'Không có BCC';
    }

    // concat into format "to ..., ..., ..., bcc: ..., ...,"
    if (bccText.isNotEmpty) {
      return 'to $toText, bcc: $bccText';
    } else {
      return 'to $toText';
    }
  }
}
