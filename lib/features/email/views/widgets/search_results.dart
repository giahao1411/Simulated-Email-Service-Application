import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/features/email/controllers/email_service.dart';
import 'package:email_application/features/email/models/email.dart';
import 'package:email_application/features/email/models/email_search_result.dart';
import 'package:email_application/features/email/models/email_state.dart';
import 'package:email_application/features/email/models/search_filters.dart';
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
    required this.filters,
    super.key,
  });

  final String searchQuery;
  final String currentCategory;
  final SearchFilters filters;

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
        oldWidget.currentCategory != widget.currentCategory ||
        !_filtersEqual(oldWidget.filters, widget.filters)) {
      _performSearch();
    }
  }

  bool _filtersEqual(SearchFilters a, SearchFilters b) {
    return a.label == b.label &&
        a.from == b.from &&
        a.to == b.to &&
        a.hasAttachments == b.hasAttachments &&
        a.dateRange == b.dateRange;
  }

  Future<void> _performSearch() async {
    if (widget.searchQuery.isEmpty && !widget.filters.hasActiveFilters) {
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
      final emailData = await emailStream.first;

      final query = widget.searchQuery.trim().toLowerCase();
      final filteredEmails =
          emailData.where((item) {
            final email = item['email'] as Email;
            final state = item['state'] as EmailState;

            // Text search
            var matchesText = true;
            if (query.isNotEmpty) {
              final from = email.from.trim().toLowerCase();
              final subject = email.subject.trim().toLowerCase();
              final body = email.body.trim().toLowerCase();
              final to = email.to
                  .map((recipient) => recipient.trim().toLowerCase())
                  .join(' ');
              final cc = email.cc
                  .map((recipient) => recipient.trim().toLowerCase())
                  .join(' ');
              final bcc = email.bcc
                  .map((recipient) => recipient.trim().toLowerCase())
                  .join(' ');
              matchesText =
                  from.contains(query) ||
                  subject.contains(query) ||
                  body.contains(query) ||
                  to.contains(query) ||
                  cc.contains(query) ||
                  bcc.contains(query);
            }

            // Filter by sender
            var matchesFrom = true;
            if (widget.filters.from != null) {
              matchesFrom = email.from.toLowerCase().contains(
                widget.filters.from!.toLowerCase(),
              );
            }

            // Filter by recipient
            var matchesTo = true;
            if (widget.filters.to != null) {
              final filterTo = widget.filters.to!.toLowerCase();
              matchesTo =
                  email.to.any(
                    (recipient) => recipient.toLowerCase().contains(filterTo),
                  ) ||
                  email.cc.any(
                    (recipient) => recipient.toLowerCase().contains(filterTo),
                  ) ||
                  email.bcc.any(
                    (recipient) => recipient.toLowerCase().contains(filterTo),
                  );
            }

            // Filter by attachments
            var matchesAttachments = true;
            if (widget.filters.hasAttachments != null) {
              matchesAttachments =
                  email.hasAttachments == widget.filters.hasAttachments;
            }

            // Filter by date range
            var matchesDateRange = true;
            if (widget.filters.dateRange != null) {
              final emailDate = email.timestamp;
              final startDate = widget.filters.dateRange!.start;
              final endDate = widget.filters.dateRange!.end.add(
                const Duration(days: 1),
              );
              matchesDateRange =
                  emailDate.isAfter(startDate) && emailDate.isBefore(endDate);
            }

            // Filter by label (from EmailState)
            var matchesLabel = true;
            if (widget.filters.label != null) {
              matchesLabel = state.labels.contains(widget.filters.label);
            }

            return matchesText &&
                matchesFrom &&
                matchesTo &&
                matchesAttachments &&
                matchesDateRange &&
                matchesLabel;
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
            subject: email.subject.isEmpty ? '(No Subject)' : email.subject,
            preview: email.body.isEmpty ? '(No Content)' : email.body,
            time: DateFormat.formatTimestamp(email.timestamp),
            avatarUrl: '',
            isStarred: state.starred,
            avatarText:
                senderName.isNotEmpty ? senderName[0].toUpperCase() : 'A',
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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi tìm kiếm email: $e')));
      }
    }
  }

  Widget _buildFilterSummary() {
    final activeFilters = <String>[];

    if (widget.filters.label != null) {
      activeFilters.add('Nhãn: ${widget.filters.label}');
    }
    if (widget.filters.from != null) {
      activeFilters.add('Từ: ${widget.filters.from}');
    }
    if (widget.filters.to != null) {
      activeFilters.add('Đến: ${widget.filters.to}');
    }
    if (widget.filters.hasAttachments != null) {
      activeFilters.add(
        'Tệp đính kèm: ${widget.filters.hasAttachments! ? "Có" : "Không"}',
      );
    }
    if (widget.filters.dateRange != null) {
      final start = widget.filters.dateRange!.start;
      final end = widget.filters.dateRange!.end;
      activeFilters.add(
        'Ngày: ${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}',
      );
    }

    if (activeFilters.isEmpty) return const SizedBox.shrink();

    final themeProvider = Provider.of<ThemeManage>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final textColor = isDarkMode ? Colors.white70 : Colors.grey[600];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bộ lọc đang áp dụng:',
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children:
                activeFilters
                    .map(
                      (filter) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isDarkMode
                                  ? Colors.blue.shade800
                                  : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            color:
                                isDarkMode
                                    ? Colors.blue.shade200
                                    : Colors.blue.shade800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
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
      return Column(
        children: [
          if (widget.filters.hasActiveFilters) _buildFilterSummary(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: iconColor),
                  const SizedBox(height: 16),
                  Text(
                    widget.searchQuery.isNotEmpty
                        ? 'Không tìm thấy kết quả cho "${widget.searchQuery}"'
                        : 'Không tìm thấy email nào phù hợp với bộ lọc',
                    style: TextStyle(color: textColor, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.filters.hasActiveFilters) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Thử điều chỉnh bộ lọc để xem thêm kết quả',
                      style: TextStyle(color: textColor, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.filters.hasActiveFilters) _buildFilterSummary(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.searchQuery.isNotEmpty
                    ? 'Kết quả cho "${widget.searchQuery}"'
                    : 'Kết quả tìm kiếm',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${_results.length} kết quả',
                style: TextStyle(color: textColor, fontSize: 14),
              ),
            ],
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
