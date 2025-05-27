import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/draft.dart';
import 'package:email_application/features/email/models/email_state.dart';
import 'package:email_application/features/email/views/screens/compose_screen.dart';
import 'package:email_application/features/email/views/widgets/draft_tile.dart';
import 'package:flutter/material.dart';

class DraftList extends StatelessWidget {
  const DraftList({
    required this.emailService,
    required this.currentCategory,
    required this.draftStream,
    required this.onRefresh,
    super.key,
  });

  final EmailService emailService;
  final String currentCategory;
  final Stream<List<Map<String, dynamic>>> draftStream;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: draftStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          final draftsWithState = snapshot.data ?? [];
          if (draftsWithState.isEmpty) {
            return const Center(child: Text('Không có thư nháp'));
          }
          return ListView.builder(
            itemCount: draftsWithState.length,
            itemBuilder: (context, index) {
              final draft = draftsWithState[index]['email'] as Draft;
              final state = draftsWithState[index]['state'] as EmailState;
              return DraftTile(
                draft: draft,
                state: state,
                index: index,
                emailService: emailService,
                onStarToggled: onRefresh,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => ComposeScreen(draft: draft),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
