class EmailValidator {
  static RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  static bool isValidEmail(String email) {
    return emailRegex.hasMatch(email.trim());
  }

  static bool validateEmails(String input) {
    if (input.isEmpty) return true; // Cho phép trống với cc, bcc
    final emails = input
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty);
    return emails.every(emailRegex.hasMatch);
  }

  static List<String> parseEmails(String emailString) {
    return emailString
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}
