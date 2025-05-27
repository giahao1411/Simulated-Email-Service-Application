import 'package:flutter/material.dart';
import 'package:email_application/features/email/models/search_filters.dart';
import 'package:email_application/features/email/controllers/label_controller.dart';

class AdvancedSearchFilters extends StatefulWidget {
  const AdvancedSearchFilters({required this.onFiltersChanged, super.key});

  final void Function(SearchFilters) onFiltersChanged;

  @override
  State<AdvancedSearchFilters> createState() => _AdvancedSearchFiltersState();
}

class _AdvancedSearchFiltersState extends State<AdvancedSearchFilters> {
  String? selectedLabel;
  String? selectedFrom;
  String? selectedTo;
  bool? hasAttachments;
  DateTimeRange? selectedDateRange;

  final LabelController _labelController = LabelController();
  List<String> labels = [];

  final List<String> commonSenders = [];
  final List<String> commonRecipients = [];

  @override
  void initState() {
    super.initState();
    _loadLabels();
    _loadCommonSendersAndRecipients();
  }

  Future<void> _loadLabels() async {
    final loadedLabels = await _labelController.loadLabels();
    setState(() {
      labels = loadedLabels;
    });
  }

  Future<void> _loadCommonSendersAndRecipients() async {
    setState(() {
      commonSenders.addAll([
        'Gmail Team',
        'Facebook',
        'LinkedIn',
        'Amazon',
        'Apple',
        'Microsoft',
      ]);
      commonRecipients.addAll([
        'me@gmail.com',
        'work@company.com',
        'personal@gmail.com',
      ]);
    });
  }

  void _updateFilters() {
    final filters = SearchFilters(
      label: selectedLabel,
      from: selectedFrom,
      to: selectedTo,
      hasAttachments: hasAttachments,
      dateRange: selectedDateRange,
    );
    widget.onFiltersChanged(filters);
  }

  void _clearAllFilters() {
    setState(() {
      selectedLabel = null;
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
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: Colors.blue),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
      });
      _updateFilters();
    }
  }

  Widget _buildFilterChip({
    required String label,
    required String? value,
    required VoidCallback onTap,
    VoidCallback? onDeleted,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isSelected = value != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
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
                color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
            ),
            if (isSelected && onDeleted != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDeleted,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showLabelPicker() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chọn nhãn',
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
              const SizedBox(height: 8),
              ...labels.map(
                (label) => ListTile(
                  title: Text(label),
                  onTap: () {
                    setState(() {
                      selectedLabel = label;
                    });
                    _updateFilters();
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFromPicker() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Từ người gửi',
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
              const SizedBox(height: 8),
              ...commonSenders.map(
                (sender) => ListTile(
                  title: Text(sender),
                  onTap: () {
                    setState(() {
                      selectedFrom = sender;
                    });
                    _updateFilters();
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showToPicker() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Đến người nhận',
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
              const SizedBox(height: 8),
              ...commonRecipients.map(
                (recipient) => ListTile(
                  title: Text(recipient),
                  onTap: () {
                    setState(() {
                      selectedTo = recipient;
                    });
                    _updateFilters();
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAttachmentPicker() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Có tệp đính kèm'),
                onTap: () {
                  setState(() {
                    hasAttachments = true;
                  });
                  _updateFilters();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Không có tệp đính kèm'),
                onTap: () {
                  setState(() {
                    hasAttachments = false;
                  });
                  _updateFilters();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters =
        selectedLabel != null ||
        selectedFrom != null ||
        selectedTo != null ||
        hasAttachments != null ||
        selectedDateRange != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ), // Giảm padding để tiết kiệm không gian
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildFilterChip(
                  label: 'Nhãn',
                  value: selectedLabel,
                  onTap: _showLabelPicker,
                  onDeleted:
                      selectedLabel != null
                          ? () {
                            setState(() {
                              selectedLabel = null;
                            });
                            _updateFilters();
                          }
                          : null,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Từ',
                  value: selectedFrom,
                  onTap: _showFromPicker,
                  onDeleted:
                      selectedFrom != null
                          ? () {
                            setState(() {
                              selectedFrom = null;
                            });
                            _updateFilters();
                          }
                          : null,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Đến',
                  value: selectedTo,
                  onTap: _showToPicker,
                  onDeleted:
                      selectedTo != null
                          ? () {
                            setState(() {
                              selectedTo = null;
                            });
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
                            setState(() {
                              hasAttachments = null;
                            });
                            _updateFilters();
                          }
                          : null,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Ngày',
                  value:
                      selectedDateRange != null
                          ? '${selectedDateRange!.start.day}/${selectedDateRange!.start.month} - ${selectedDateRange!.end.day}/${selectedDateRange!.end.month}'
                          : null,
                  onTap: _selectDateRange,
                  onDeleted:
                      selectedDateRange != null
                          ? () {
                            setState(() {
                              selectedDateRange = null;
                            });
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
              TextButton(
                onPressed: _clearAllFilters,
                child: const Text('Xóa tất cả bộ lọc'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
