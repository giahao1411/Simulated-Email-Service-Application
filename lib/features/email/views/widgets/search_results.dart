import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/models/email_search_result.dart';
import 'package:email_application/features/email/models/email_state.dart';
import 'package:email_application/features/email/providers/theme_manage.dart';
import 'package:email_application/features/email/utils/date_format.dart';
import 'package:email_application/features/email/views/screens/mail_detail_screen.dart';
import 'package:email_application/features/email/views/widgets/email_search_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchResults extends StatefulWidget {
  const SearchResults({
    required this.searchQuery,
    required this.currentCategory,
    super.key,
  });

  final String searchQuery;
  final String currentCategory;

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  List<EmailSearchResult> _results = [];
  List<Map<String, dynamic>> _filteredEmails = [];
  bool _isLoading = false;
  final EmailService _emailService = EmailService();

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  @override
  void didUpdateWidget(SearchResults oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.currentCategory != widget.currentCategory) {
      _performSearch();
    }
  }

  Future<void> _performSearch() async {
    if (widget.searchQuery.trim().isEmpty) {
      setState(() {
        _results = [];
        _filteredEmails = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final emailStream =
          _emailService.getEmails(widget.currentCategory).asBroadcastStream();
      final emails = await emailStream.first;

      final query = widget.searchQuery.trim().toLowerCase();
      final filteredEmails =
          emails.where((item) {
            final email = item['email'] as Email;
            final from = email.from.trim().toLowerCase();
            final subject = email.subject.trim().toLowerCase();
            final body = email.body.trim().toLowerCase();
            final to = email.to
                .map((recipient) => recipient.trim().toLowerCase())
                .join(' ');
            return from.contains(query) ||
                subject.contains(query) ||
                body.contains(query) ||
                to.contains(query);
          }).toList();

      final searchResults = await Future.wait(
        filteredEmails.map((item) async {
          final email = item['email'] as Email;
          final state = item['state'] as EmailState;
          final senderName = await _emailService.getUserFullNameByEmail(
            email.from,
          );
          return EmailSearchResult(
            senderName: senderName,
            subject: email.subject,
            preview: email.body,
            time: DateFormat.formatTimestamp(email.timestamp),
            avatarUrl: '',
            isStarred: state.starred,
            avatarText: senderName.isNotEmpty ? senderName[0] : 'A',
            backgroundColor: Colors.blue,
            email: email,
          );
        }).toList(),
      );

      setState(() {
        _results = searchResults;
        _filteredEmails = filteredEmails;
        _isLoading = false;
      });
    } on Exception catch (e) {
      setState(() {
        _results = [];
        _filteredEmails = [];
        _isLoading = false;
      });
      AppFunctions.debugPrint('Error searching emails: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeManage>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final textColor = isDarkMode ? Colors.white70 : Colors.grey[600];
    final iconColor = isDarkMode ? Colors.white38 : Colors.grey[400];

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: iconColor),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy kết quả cho "${widget.searchQuery}"',
              style: TextStyle(color: textColor, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Kết quả trong thư',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _results.length,
            itemBuilder: (context, index) {
              return EmailSearchItem(
                result: _results[index],
                searchQuery: widget.searchQuery,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<MailDetail>(
                      builder:
                          (context) => MailDetail(
                            email: _results[index].email!,
                            state:
                                _filteredEmails[index]['state'] as EmailState,
                            onRefresh: _performSearch,
                          ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
