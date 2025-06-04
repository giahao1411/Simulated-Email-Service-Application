import 'package:email_application/features/email/models/email.dart';

class EmailReply {
  static Email createCustomReply(
    Email originalEmail,
    String senderEmail,
    String replyBody, {
    List<String> ccEmails = const [],
    List<String> bccEmails = const [],
    List<Map<String, dynamic>> attachment = const [],
  }) {
    return Email(
      id: '',
      from: senderEmail,
      to: [originalEmail.from], // Reply cho người gửi gốc
      cc: ccEmails,
      bcc: bccEmails,
      subject: 'Re: ${originalEmail.subject}',
      body:
          '$replyBody\n\nOn ${originalEmail.timestamp}, ${originalEmail.from} wrote:\n${originalEmail.body}',
      timestamp: DateTime.now(),
      hasAttachments: attachment.isNotEmpty,
      attachments: attachment.cast<Map<String, dynamic>>(),
      inReplyTo: originalEmail.id,
    );
  }
}
