import 'package:email_application/core/constants/app_strings.dart';
import 'package:email_application/features/email/views/widgets/email_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ComposeBody extends StatefulWidget {
  const ComposeBody({
    required this.toController,
    required this.fromController,
    required this.ccController,
    required this.bccController,
    required this.subjectController,
    required this.bodyController,
    super.key,
  });

  final TextEditingController toController;
  final TextEditingController fromController;
  final TextEditingController ccController;
  final TextEditingController bccController;
  final TextEditingController subjectController;
  final TextEditingController bodyController;

  @override
  State<ComposeBody> createState() => _ComposeBodyState();
}

class _ComposeBodyState extends State<ComposeBody> {
  bool showCcBcc = false;

  @override
  void initState() {
    super.initState();
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    widget.fromController.text = userEmail ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    print('ComposeBody - isDarkMode: $isDarkMode'); // Debug
    final labelColor = isDarkMode ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 16),
              child: Text(
                AppStrings.to,
                style: TextStyle(color: labelColor, fontSize: 16),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: EmailTextField(
                  controller: widget.toController,
                  labelText: '',
                  useLabelAsFixed: true,
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        showCcBcc = !showCcBcc;
                      });
                    },
                    child: Icon(
                      showCcBcc ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Divider(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
          height: 1,
          thickness: 0.75,
        ),
        if (showCcBcc) ...[
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16, left: 16),
                child: Text(
                  AppStrings.cc,
                  style: TextStyle(color: labelColor, fontSize: 16),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: EmailTextField(
                    controller: widget.ccController,
                    labelText: '',
                    useLabelAsFixed: true,
                  ),
                ),
              ),
            ],
          ),
          Divider(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
            height: 1,
            thickness: 0.75,
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16, left: 16),
                child: Text(
                  AppStrings.bcc,
                  style: TextStyle(color: labelColor, fontSize: 16),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: EmailTextField(
                    controller: widget.bccController,
                    labelText: '',
                    useLabelAsFixed: true,
                  ),
                ),
              ),
            ],
          ),
          Divider(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
            height: 1,
            thickness: 0.75,
          ),
        ],
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 16),
              child: Text(
                AppStrings.from,
                style: TextStyle(color: labelColor, fontSize: 16),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: EmailTextField(
                  controller: widget.fromController,
                  labelText: '',
                  useLabelAsFixed: true,
                  suffixIcon: Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
        Divider(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
          height: 1,
          thickness: 0.75,
        ),
        EmailTextField(
          controller: widget.subjectController,
          labelText: AppStrings.subject,
        ),
        Divider(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
          height: 1,
          thickness: 0.75,
        ),
        Expanded(
          child: EmailTextField(
            controller: widget.bodyController,
            labelText: AppStrings.composeEmail,
            keyboardType: TextInputType.multiline,
          ),
        ),
      ],
    );
  }
}
