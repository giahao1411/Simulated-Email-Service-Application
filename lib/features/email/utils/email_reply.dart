import 'package:email_application/features/email/models/email.dart';

class EmailReply {
  static Email createCustomReply(
    Email originalEmail,
    String currentUserEmail,
    String replyBody,
  ) {
    final newSubject =
        originalEmail.subject.startsWith('Re: ')
            ? originalEmail.subject
            : 'Re: ${originalEmail.subject}';
    return Email(
      id: '',
      from: currentUserEmail,
      to: [originalEmail.from],
      subject: newSubject,
      body: replyBody,
      timestamp: DateTime.now(),
      inReplyTo: originalEmail.id,
    );
  }
}
