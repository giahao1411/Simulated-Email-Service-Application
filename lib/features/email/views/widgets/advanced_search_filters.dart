import 'package:flutter/material.dart';
import 'package:email_application/features/email/models/search_filters.dart';
import 'package:email_application/core/constants/app_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // Chỉ giữ các nhãn cố định, thêm "Starred", bỏ "Archive", "All Mail", và nhãn từ drawer
  final List<String> drawerCategories = [
    'Inbox',
    'Sent',
    'Draft',
    'Important',
    'Spam',
    'Trash',
    'Starred',
  ];

  // Danh sách động sẽ được cập nhật từ Firestore
  List<String> commonSenders = [];
  List<String> commonRecipients = [];

  @override
  void initState() {
    super.initState();
    _fetchEmailContacts(); // Gọi hàm để lấy danh sách email
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFilters();
    });
  }

  // Hàm lấy danh sách email từ Firestore
  Future<void> _fetchEmailContacts() async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail == null) {
      AppFunctions.debugPrint('Không thể lấy email người dùng');
      return;
    }

    try {
      // Truy vấn email nhận (lấy danh sách "from")
      final receivedEmailsSnapshot =
          await FirebaseFirestore.instance
              .collection('emails')
              .where('to', arrayContains: userEmail)
              .orderBy('timestamp', descending: true)
              .limit(50) // Giới hạn để tránh tải quá nhiều dữ liệu
              .get();

      // Truy vấn email gửi (lấy danh sách "to")
      final sentEmailsSnapshot =
          await FirebaseFirestore.instance
              .collection('emails')
              .where('from', isEqualTo: userEmail)
              .orderBy('timestamp', descending: true)
              .limit(50) // Giới hạn để tránh tải quá nhiều dữ liệu
              .get();

      // Lấy danh sách "from" từ email nhận
      final senders =
          receivedEmailsSnapshot.docs
              .map((doc) => doc['from'] as String)
              .toSet() // Loại bỏ trùng lặp
              .toList();

      // Lấy danh sách "to" từ email gửi
      final recipients = <String>{};
      for (var doc in sentEmailsSnapshot.docs) {
        final toList = doc['to'] as List<dynamic>;
        recipients.addAll(toList.cast<String>());
      }

      setState(() {
        commonSenders = senders;
        commonRecipients = recipients.toList();
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
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isSelected = value != null && value.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? (isDarkMode ? Colors.blue.shade800 : Colors.blue.shade100)
                  : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
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
                            ? Colors.blue.shade200
                            : Colors.blue.shade800)
                        : (isDarkMode ? Colors.white70 : Colors.grey.shade700),
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
                          ? Colors.blue.shade200
                          : Colors.blue.shade800)
                      : (isDarkMode ? Colors.white70 : Colors.grey.shade700),
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
                              ? Colors.blue.shade200
                              : Colors.blue.shade800)
                          : (isDarkMode
                              ? Colors.white70
                              : Colors.grey.shade700),
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

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                ...options.map(
                  (item) => ListTile(
                    title: Text(_getCategoryDisplayName(item)),
                    trailing:
                        _isItemSelected(title, item)
                            ? const Icon(Icons.check, color: Colors.blue)
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
                      _updateFilters(); // Đảm bảo cập nhật ngay lập tức
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
      'Sent': 'Thư đã gửi',
      'Draft': 'Thư nháp',
      'Important': 'Quan trọng',
      'Spam': 'Thư rác',
      'Trash': 'Thùng rác',
      'Starred': 'Có đánh dấu sao',
    };
    return categoryNames[category] ?? category;
  }

  void _showAttachmentPicker() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                ListTile(
                  title: const Text('Có tệp đính kèm'),
                  trailing:
                      hasAttachments == true
                          ? const Icon(Icons.check, color: Colors.blue)
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
                  title: const Text('Không có tệp đính kèm'),
                  trailing:
                      hasAttachments == false
                          ? const Icon(Icons.check, color: Colors.blue)
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
    final start = dateRange.start;
    final end = dateRange.end;
    return '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year} - ${end.day.toString().padLeft(2, '0')}/${end.month.toString().padLeft(2, '0')}/${end.year}';
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters =
        selectedCategory != null ||
        selectedFrom != null ||
        selectedTo != null ||
        hasAttachments != null ||
        selectedDateRange != null;

    // Loại bỏ lọc availableCategories, sử dụng toàn bộ drawerCategories
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
                  child: const Text('Xóa tất cả bộ lọc'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
