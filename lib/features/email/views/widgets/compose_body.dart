import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/core/constants/app_strings.dart';
import 'package:email_application/features/email/providers/compose_state.dart';
import 'package:email_application/features/email/providers/theme_manage.dart';
import 'package:email_application/features/email/views/widgets/email_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final themeProvider = Provider.of<ThemeManage>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final colorScheme = Theme.of(context).colorScheme;
    final composeState = Provider.of<ComposeState>(context);
    AppFunctions.debugPrint('ComposeBody - isDarkMode: $isDarkMode');

    final labelColor = isDarkMode ? Colors.white70 : colorScheme.onSurface;
    final iconColor = isDarkMode ? Colors.white70 : colorScheme.onSurface;
    final borderColor = isDarkMode ? Colors.white70 : Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border:
                showCcBcc
                    ? null
                    : Border(
                      bottom: BorderSide(color: borderColor, width: 0.75),
                    ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16, left: 16),
                child: Text(
                  AppStrings.to,
                  style: TextStyle(color: labelColor, fontSize: 16),
                ),
              ),
              Expanded(
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
                      showCcBcc
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
                child: EmailTextField(
                  controller: widget.ccController,
                  labelText: '',
                  useLabelAsFixed: true,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: borderColor, width: 0.75),
              ),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16, left: 16),
                  child: Text(
                    AppStrings.bcc,
                    style: TextStyle(color: labelColor, fontSize: 16),
                  ),
                ),
                Expanded(
                  child: EmailTextField(
                    controller: widget.bccController,
                    labelText: '',
                    useLabelAsFixed: true,
                  ),
                ),
              ],
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: borderColor, width: 0.75)),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16, left: 16),
                child: Text(
                  AppStrings.from,
                  style: TextStyle(color: labelColor, fontSize: 16),
                ),
              ),
              Expanded(
                child: EmailTextField(
                  controller: widget.fromController,
                  labelText: '',
                  useLabelAsFixed: true,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: borderColor, width: 0.75)),
          ),
          child: EmailTextField(
            controller: widget.subjectController,
            labelText: AppStrings.subject,
          ),
        ),
        // Thêm vào phần hiển thị file attachment trong ComposeBody
        if (composeState.selectedFile != null) ...[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.attach_file, color: iconColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            composeState.selectedFile!.name,
                            style: TextStyle(
                              color: labelColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            composeState.getFileSize(),
                            style: TextStyle(
                              color: labelColor.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.clear, color: iconColor),
                      onPressed: () {
                        composeState.clearSelectedFile();
                      },
                    ),
                  ],
                ),

                // Hiển thị preview ảnh nếu là file ảnh
                if (composeState.isImageFile() &&
                    composeState.fileBytes != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(
                      maxHeight: 200,
                      maxWidth: double.infinity,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        composeState.fileBytes!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 100,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Text('Không thể hiển thị ảnh'),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
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
