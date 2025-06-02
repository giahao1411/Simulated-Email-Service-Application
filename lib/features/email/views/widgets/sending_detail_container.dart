import 'package:email_application/core/constants/app_strings.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/utils/date_format.dart';
import 'package:flutter/material.dart';

class SendingDetailContainer extends StatelessWidget {
  const SendingDetailContainer({
    required this.email,
    required this.onSurface70,
    super.key,
  });

  final Email email;
  final Color onSurface70;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(top: 4, bottom: 20, right: 8),
      decoration: BoxDecoration(
        border: Border.all(color: onSurface70.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 60,
                child: Text(
                  AppStrings.from,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: onSurface70,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  email.from.isEmpty ? '(No sender)' : email.from,
                  style: TextStyle(color: onSurface70),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (email.to.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        AppStrings.to,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: onSurface70,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 2,
                        children:
                            email.to
                                .map(
                                  (emailAddress) => Text(
                                    emailAddress,
                                    style: TextStyle(color: onSurface70),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          if (email.cc.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        AppStrings.cc,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: onSurface70,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 2,
                        children:
                            email.cc
                                .map(
                                  (emailAddress) => Text(
                                    emailAddress,
                                    style: TextStyle(color: onSurface70),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          if (email.bcc.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        AppStrings.bcc,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: onSurface70,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 2,
                        children:
                            email.bcc
                                .map(
                                  (emailAddress) => Text(
                                    emailAddress,
                                    style: TextStyle(color: onSurface70),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 60,
                child: Text(
                  AppStrings.date,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: onSurface70,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  DateFormat.formatDetailedTimestamp(email.timestamp),
                  style: TextStyle(color: onSurface70),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
