import 'package:flutter/material.dart';

class MailDetailScreen extends StatefulWidget {
  const MailDetailScreen({super.key});

  @override
  State<MailDetailScreen> createState() => _MailDetailScreenState();
}

class _MailDetailScreenState extends State<MailDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mail Detail')),
      body: const Center(child: Text('Mail Detail Screen')),
    );
  }
}
