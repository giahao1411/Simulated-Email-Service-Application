import 'dart:io';
import 'dart:math';

import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/models/email_state.dart';
import 'package:email_application/features/email/utils/date_format.dart';
import 'package:email_application/features/email/utils/photo_util.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;

class EmailTile extends StatelessWidget {
  const EmailTile({
    required this.email,
    required this.state,
    required this.index,
    required this.emailService,
    required this.currentCategory,
    required this.senderFullName,
    this.onStarToggled,
    this.onTap,
    super.key,
  });

  final Email email;
  final EmailState state;
  final int index;
  final EmailService emailService;
  final String currentCategory;
  final String senderFullName;
  final VoidCallback? onStarToggled;
  final VoidCallback? onTap;

  // Hàm loại bỏ thẻ HTML
  String stripHtmlTags(String htmlText) {
    final document = parse(htmlText);
    final parsedString = document.body?.text.trim() ?? htmlText;
    return parsedString;
  }

  // Hàm định dạng tiêu đề email
  String formatSubject(String subject) {
    return DateFormat.formatTextWithTimestamp(subject);
  }

  // Hàm lấy dòng đầu tiên
  String getFirstLine(String text) {
    if (text.isEmpty) return '(Không có nội dung)';
    final cleanText = stripHtmlTags(text);
    final formattedText = DateFormat.formatTextWithTimestamp(cleanText);
    final lines = formattedText.split('\n');
    var firstLine = lines.first.trim();
    final dateRegExp = RegExp(r'^\d{2}/\d{2}/\d{4}\s+lúc\s+\d{2}:\d{2}');
    if (dateRegExp.hasMatch(firstLine) && !firstLine.startsWith('Vào')) {
      firstLine = 'Vào $firstLine';
    }
    final wroteIndex = firstLine.indexOf('đã viết:');
    if (wroteIndex != -1) {
      firstLine = firstLine.substring(0, wroteIndex + 'đã viết:'.length);
    }
    return firstLine.isEmpty ? '(Không có nội dung)' : firstLine;
  }

  // Hàm lấy chữ cái đầu của firstName
  String _getInitial(String senderName) {
    final parts = senderName.trim().split(' ');
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  // Hàm tạo màu ngẫu nhiên
  Color _getRandomColor() {
    return Color(0xFF000000 + (Random().nextInt(0xFFFFFF))).withOpacity(1);
  }

  @override
  Widget build(BuildContext context) {
    final senderNameWidget = Text(
      senderFullName,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontSize: 16,
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: state.read ? FontWeight.normal : FontWeight.bold,
      ),
    );

    final cleanBody = stripHtmlTags(
      email.body.isEmpty ? '(Không có nội dung)' : email.body,
    );
    final firstLineBody = getFirstLine(cleanBody);

    return FutureBuilder<String>(
      future: PhotoUtil.getPhotoUrlByEmail(email.from),
      builder: (context, snapshot) {
        ImageProvider? avatarImage;
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data!.isNotEmpty) {
          avatarImage =
              snapshot.data!.startsWith('http')
                  ? NetworkImage(snapshot.data!)
                  : FileImage(File(snapshot.data!)) as ImageProvider;
        }

        return InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: avatarImage,
                    backgroundColor:
                        avatarImage == null ? _getRandomColor() : null,
                    child:
                        avatarImage == null
                            ? Text(
                              _getInitial(senderFullName),
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            )
                            : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: senderNameWidget),
                          Text(
                            DateFormat.formatTimestamp(email.timestamp),
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        email.subject.isEmpty
                            ? '(Không có chủ đề)'
                            : formatSubject(email.subject),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight:
                              state.read ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              firstLineBody,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          SizedBox(
                            width: 22,
                            height: 26,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  state.starred
                                      ? Icons.star
                                      : Icons.star_outline,
                                  color:
                                      state.starred
                                          ? Colors.amber
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.6),
                                  size: 25,
                                ),
                                onPressed: () async {
                                  try {
                                    await emailService.toggleStar(
                                      email.id,
                                      state.starred,
                                    );
                                    onStarToggled?.call();
                                  } on Exception catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text('Lỗi: $e')),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
