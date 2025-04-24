import 'package:flutter/material.dart';
import '../controllers/email_service.dart';

class ComposeScreen extends StatefulWidget {
  const ComposeScreen({super.key});

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  final TextEditingController toController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  final EmailService emailService = EmailService();

  Future<void> handleSendEmail() async {
    await emailService.sendEmail(
      toController.text,
      subjectController.text,
      bodyController.text,
    );
    Navigator.pop(context);
  }

  Future<void> handleSaveDraft() async {
    await emailService.saveDraft(
      toController.text,
      subjectController.text,
      bodyController.text,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Soạn thư"),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: handleSaveDraft),
          IconButton(icon: const Icon(Icons.send), onPressed: handleSendEmail),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: toController,
              decoration: const InputDecoration(labelText: "Đến"),
            ),
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(labelText: "Chủ đề"),
            ),
            Expanded(
              child: TextField(
                controller: bodyController,
                decoration: const InputDecoration(labelText: "Nội dung"),
                maxLines: null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
