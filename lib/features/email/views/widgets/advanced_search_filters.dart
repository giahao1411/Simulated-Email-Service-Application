import 'package:flutter/material.dart';
import 'package:email_application/features/email/models/search_filters.dart';
import 'package:email_application/core/constants/app_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:email_application/features/email/providers/theme_manage.dart';

class AdvancedSearchFilters extends StatefulWidget {
  const AdvancedSearchFilters({
    required this.onFiltersChanged,
    required this.currentCategory,
    super.key,
  });

  final void Function(SearchFilters) onFiltersChanged;
  final String currentCategory;

  @override
  State<AdvancedSearchFilters> createState() => _AdvancedSearchFiltersState();
}

class _AdvancedSearchFiltersState extends State<AdvancedSearchFilters> {
  String? selectedCategory;
  String? selectedFrom;
  String? selectedTo;
  bool? hasAttachments;
  DateTimeRange? selectedDateRange;

  final List<String> drawerCategories = [
    'Inbox',
    'Starred',
    'Sent',
    'Draft',
    'Important',
    'Spam',
    'Trash',
  ];

  List<String> commonSenders = [];
  List<String> commonRecipients = [];

  @override
  void initState() {
    super.initState();
    _fetchEmailContacts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFilters();
    });
  }

  Future<void> _fetchEmailContacts() async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail == null) {
      AppFunctions.debugPrint('Không thể lấy email người dùng');
      return;
    }

    try {
      final emailsSnapshot =
          await FirebaseFirestore.instance
              .collection('emails')
              .where(
                Filter.or(
                  Filter('from', isEqualTo: userEmail),
                  Filter('to', arrayContains: userEmail),
                  Filter('cc', arrayContains: userEmail),
                  Filter('bcc', arrayContains: userEmail),
                ),
              )
              .orderBy('timestamp', descending: true)
              .limit(200)
              .get();

      final senders = <String>{};
      final recipients = <String>{};

      for (var doc in emailsSnapshot.docs) {
        final data = doc.data();
        final from = data['from'] as String?;
        final toList =
            data['to'] is Iterable
                ? List<String>.from(data['to'] as Iterable)
                : <String>[];
        final ccList =
            data['cc'] is Iterable
                ? List<String>.from(data['cc'] as Iterable)
                : <String>[];
        final bccList =
            data['bcc'] is Iterable
                ? List<String>.from(data['bcc'] as Iterable)
                : <String>[];

        if (from == userEmail) {
          recipients.addAll(toList.where((e) => e != userEmail));
          recipients.addAll(ccList.where((e) => e != userEmail));
          recipients.addAll(bccList.where((e) => e != userEmail));
        } else {
          if (from != null && from != userEmail) {
            senders.add(from);
          }
          final userIsRecipient =
              toList.contains(userEmail) ||
              ccList.contains(userEmail) ||
              bccList.contains(userEmail);
          if (userIsRecipient && from != null && from != userEmail) {
            senders.add(from);
          }
        }
      }

      setState(() {
        commonSenders = senders.toList()..sort();
        commonRecipients = recipients.toList()..sort();
      });

      AppFunctions.debugPrint('Fetched senders: $commonSenders');
      AppFunctions.debugPrint('Fetched recipients: $commonRecipients');
    } catch (e) {
      AppFunctions.debugPrint('Lỗi khi lấy danh sách email: $e');
    }
  }

  void _updateFilters() {
    if (!mounted) return;

    AppFunctions.debugPrint(
      'Updated filters: category=$selectedCategory, from=$selectedFrom, to=$selectedTo, hasAttachments=$hasAttachments, dateRange=$selectedDateRange',
    );

    final filters = SearchFilters(
      category: selectedCategory,
      from: selectedFrom?.isNotEmpty == true ? selectedFrom : null,
      to: selectedTo?.isNotEmpty == true ? selectedTo : null,
      hasAttachments: hasAttachments,
      dateRange: selectedDateRange,
    );
    widget.onFiltersChanged(filters);
  }

  void _clearAllFilters() {
    setState(() {
      selectedCategory = null;
      selectedFrom = null;
      selectedTo = null;
      hasAttachments = null;
      selectedDateRange = null;
    });
    _updateFilters();
  }

  Future<void> _selectDateRange() async {
    final themeProvider = Provider.of<ThemeManage>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: selectedDateRange,
      locale: const Locale('vi', 'VN'),
      helpText: 'Chọn khoảng thời gian',
      cancelText: 'Hủy',
      confirmText: 'OK',
      saveText: 'Lưu',
      errorFormatText: 'Định dạng ngày không hợp lệ',
      errorInvalidText: 'Ngày không hợp lệ',
      errorInvalidRangeText: 'Khoảng thời gian không hợp lệ',
      fieldStartHintText: 'dd/mm/yyyy',
      fieldEndHintText: 'dd/mm/yyyy',
      fieldStartLabelText: 'Ngày bắt đầu',
      fieldEndLabelText: 'Ngày kết thúc',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
                isDarkMode
                    ? ColorScheme.dark(
                      primary: primaryColor,
                      onPrimary: Colors.white,
                      surface: Colors.grey[800]!,
                      onSurface: Colors.white,
                      background: Colors.grey[900]!,
                      onBackground: Colors.white,
                      secondary: primaryColor,
                      onSecondary: Colors.white,
                    )
                    : ColorScheme.light(
                      primary: primaryColor,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black87,
                      background: Colors.white,
                      onBackground: Colors.black87,
                      secondary: primaryColor,
                      onSecondary: Colors.white,
                    ),

            dialogBackgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,

            cardTheme: CardThemeData(
              color: isDarkMode ? Colors.grey[700] : Colors.grey[50],
              elevation: 0,
            ),

            textTheme: TextTheme(
              headlineSmall: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              bodyLarge: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              bodyMedium: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
              labelLarge: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),

            dividerTheme: DividerThemeData(
              color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
              thickness: 1,
            ),

            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: isDarkMode ? Colors.grey[700] : Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
              labelStyle: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.white38 : Colors.black38,
              ),
            ),

            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            appBarTheme: AppBarTheme(
              backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
              foregroundColor: isDarkMode ? Colors.white : Colors.black87,
              elevation: 0,
              iconTheme: IconThemeData(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          child: Localizations.override(
            context: context,
            locale: const Locale('vi', 'VN'),
            child: child!,
          ),
        );
      },
    );

    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
      });
      _updateFilters();
    }
  }

  Widget _buildFilterChip({
    required String label,
    String? value,
    required VoidCallback onTap,
    VoidCallback? onDeleted,
  }) {
    final themeProvider = Provider.of<ThemeManage>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final backgroundColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final textColor = isDarkMode ? Colors.white70 : Colors.black87;
    final iconColor = isDarkMode ? Colors.white70 : Colors.black54;
    final actionColor = Theme.of(context).colorScheme.primary;
    final isSelected = value != null && value.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? (isDarkMode
                      ? actionColor.withOpacity(0.2)
                      : actionColor.withOpacity(0.1))
                  : backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isSelected ? value : label,
              style: TextStyle(
                color:
                    isSelected
                        ? (isDarkMode
                            ? actionColor.withOpacity(0.7)
                            : actionColor.withOpacity(0.9))
                        : textColor,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color:
                  isSelected
                      ? (isDarkMode
                          ? actionColor.withOpacity(0.7)
                          : actionColor.withOpacity(0.9))
                      : iconColor,
            ),
            if (isSelected && onDeleted != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDeleted,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color:
                      isSelected
                          ? (isDarkMode
                              ? actionColor.withOpacity(0.7)
                              : actionColor.withOpacity(0.9))
                          : iconColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showPicker({
    required String title,
    required List<String> options,
    required void Function(String?) onSelect,
  }) {
    if (options.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không có dữ liệu cho $title')));
      return;
    }

    final themeProvider = Provider.of<ThemeManage>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final backgroundColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final iconColor = isDarkMode ? Colors.white70 : Colors.black54;
    final actionColor = Theme.of(context).colorScheme.primary;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: backgroundColor,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: iconColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Divider(
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
                ),
                ...options.map(
                  (item) => ListTile(
                    title: Text(
                      _getCategoryDisplayName(item),
                      style: TextStyle(color: textColor),
                    ),
                    trailing:
                        _isItemSelected(title, item)
                            ? Icon(Icons.check, color: actionColor)
                            : null,
                    onTap: () {
                      setState(() {
                        if (title == 'Chọn nhãn') {
                          selectedCategory =
                              selectedCategory == item ? null : item;
                        }
                        if (title == 'Từ người gửi') {
                          selectedFrom = selectedFrom == item ? null : item;
                        }
                        if (title == 'Đến người nhận') {
                          selectedTo = selectedTo == item ? null : item;
                        }
                      });
                      _updateFilters();
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isItemSelected(String title, String item) {
    switch (title) {
      case 'Chọn nhãn':
        return selectedCategory == item;
      case 'Từ người gửi':
        return selectedFrom == item;
      case 'Đến người nhận':
        return selectedTo == item;
      default:
        return false;
    }
  }

  String _getCategoryDisplayName(String category) {
    const Map<String, String> categoryNames = {
      'Inbox': 'Hộp thư đến',
      'Sent': 'Đã gửi',
      'Draft': 'Thư nháp',
      'Important': 'Quan trọng',
      'Spam': 'Thư rác',
      'Trash': 'Thùng rác',
      'Starred': 'Có gắn dấu sao',
    };
    return categoryNames[category] ?? category;
  }

  void _showAttachmentPicker() {
    final themeProvider = Provider.of<ThemeManage>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final backgroundColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final iconColor = isDarkMode ? Colors.white70 : Colors.black54;
    final actionColor = Theme.of(context).colorScheme.primary;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: backgroundColor,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tệp đính kèm',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: iconColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Divider(
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
                ),
                ListTile(
                  title: Text(
                    'Có tệp đính kèm',
                    style: TextStyle(color: textColor),
                  ),
                  trailing:
                      hasAttachments == true
                          ? Icon(Icons.check, color: actionColor)
                          : null,
                  onTap: () {
                    setState(
                      () =>
                          hasAttachments = hasAttachments == true ? null : true,
                    );
                    _updateFilters();
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text(
                    'Không có tệp đính kèm',
                    style: TextStyle(color: textColor),
                  ),
                  trailing:
                      hasAttachments == false
                          ? Icon(Icons.check, color: actionColor)
                          : null,
                  onTap: () {
                    setState(
                      () =>
                          hasAttachments =
                              hasAttachments == false ? null : false,
                    );
                    _updateFilters();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDateRange(DateTimeRange dateRange) {
    final List<String> vietnameseMonths = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
    ];
    final start = dateRange.start;
    final end = dateRange.end;
    final startMonth = vietnameseMonths[start.month - 1];
    final endMonth = vietnameseMonths[end.month - 1];
    return '${start.day} $startMonth ${start.year} - ${end.day} $endMonth ${end.year}';
  }

  @override
  Widget build(BuildContext context) {
    final actionColor = Theme.of(context).colorScheme.primary;

    final hasActiveFilters =
        selectedCategory != null ||
        selectedFrom != null ||
        selectedTo != null ||
        hasAttachments != null ||
        selectedDateRange != null;

    final availableCategories = drawerCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (availableCategories.isNotEmpty) ...[
                  _buildFilterChip(
                    label: 'Nhãn',
                    value:
                        selectedCategory != null
                            ? _getCategoryDisplayName(selectedCategory!)
                            : null,
                    onTap:
                        () => _showPicker(
                          title: 'Chọn nhãn',
                          options: availableCategories,
                          onSelect: (v) => selectedCategory = v,
                        ),
                    onDeleted:
                        selectedCategory != null
                            ? () {
                              setState(() => selectedCategory = null);
                              _updateFilters();
                            }
                            : null,
                  ),
                  const SizedBox(width: 8),
                ],
                _buildFilterChip(
                  label: 'Từ',
                  value: selectedFrom,
                  onTap:
                      () => _showPicker(
                        title: 'Từ người gửi',
                        options: commonSenders,
                        onSelect: (v) => selectedFrom = v,
                      ),
                  onDeleted:
                      selectedFrom != null
                          ? () {
                            setState(() => selectedFrom = null);
                            _updateFilters();
                          }
                          : null,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Đến',
                  value: selectedTo,
                  onTap:
                      () => _showPicker(
                        title: 'Đến người nhận',
                        options: commonRecipients,
                        onSelect: (v) => selectedTo = v,
                      ),
                  onDeleted:
                      selectedTo != null
                          ? () {
                            setState(() => selectedTo = null);
                            _updateFilters();
                          }
                          : null,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Tệp đính kèm',
                  value:
                      hasAttachments == true
                          ? 'Có'
                          : hasAttachments == false
                          ? 'Không'
                          : null,
                  onTap: _showAttachmentPicker,
                  onDeleted:
                      hasAttachments != null
                          ? () {
                            setState(() => hasAttachments = null);
                            _updateFilters();
                          }
                          : null,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Ngày',
                  value:
                      selectedDateRange != null
                          ? _formatDateRange(selectedDateRange!)
                          : null,
                  onTap: _selectDateRange,
                  onDeleted:
                      selectedDateRange != null
                          ? () {
                            setState(() => selectedDateRange = null);
                            _updateFilters();
                          }
                          : null,
                ),
              ],
            ),
          ),
        ),
        if (hasActiveFilters) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton(
                  onPressed: _clearAllFilters,
                  child: Text(
                    'Xóa tất cả bộ lọc',
                    style: TextStyle(color: actionColor),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
