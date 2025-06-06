import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/features/email/models/search_filters.dart';
import 'package:email_application/features/email/providers/theme_manage.dart';
import 'package:email_application/features/email/utils/advance_search_utils.dart';
import 'package:email_application/features/email/views/widgets/filter_chip_widget.dart';
import 'package:email_application/features/email/views/widgets/picker_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final contacts = await AdvanceSearchUtils.fetchEmailContacts();
    setState(() {
      commonSenders = contacts['senders'] ?? [];
      commonRecipients = contacts['recipients'] ?? [];
    });
  }

  void _updateFilters() {
    if (!mounted) return;

    AppFunctions.debugPrint(
      '''Updated filters: category=$selectedCategory, from=$selectedFrom, to=$selectedTo, hasAttachments=$hasAttachments, dateRange=$selectedDateRange''',
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

    final picked = await showDateRangePicker(
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
                      secondary: primaryColor,
                      onSecondary: Colors.white,
                    )
                    : ColorScheme.light(
                      primary: primaryColor,
                      onSurface: Colors.black87,
                      secondary: primaryColor,
                      onSecondary: Colors.white,
                    ),
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
            dialogTheme: DialogThemeData(
              backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
            ),
          ),
          child: Localizations.override(
            context: context,
            locale: const Locale('vi', 'VN'),
            child: child,
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
              children: [
                if (availableCategories.isNotEmpty) ...[
                  FilterChipWidget(
                    label: 'Nhãn',
                    value:
                        selectedCategory != null
                            ? AdvanceSearchUtils.getCategoryDisplayName(
                              selectedCategory!,
                            )
                            : null,
                    onTap:
                        () => PickerBottomSheet.showPicker(
                          context: context,
                          title: 'Chọn nhãn',
                          options: availableCategories,
                          selectedValue: selectedCategory,
                          onSelect: (value) {
                            setState(() => selectedCategory = value);
                            _updateFilters();
                          },
                          getDisplayName:
                              AdvanceSearchUtils.getCategoryDisplayName,
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
                FilterChipWidget(
                  label: 'Từ',
                  value: selectedFrom,
                  onTap:
                      () => PickerBottomSheet.showPicker(
                        context: context,
                        title: 'Từ người gửi',
                        options: commonSenders,
                        selectedValue: selectedFrom,
                        onSelect: (value) {
                          setState(() => selectedFrom = value);
                          _updateFilters();
                        },
                        getDisplayName: (value) => value,
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
                FilterChipWidget(
                  label: 'Đến',
                  value: selectedTo,
                  onTap:
                      () => PickerBottomSheet.showPicker(
                        context: context,
                        title: 'Đến người nhận',
                        options: commonRecipients,
                        selectedValue: selectedTo,
                        onSelect: (value) {
                          setState(() => selectedTo = value);
                          _updateFilters();
                        },
                        getDisplayName: (value) => value,
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
                FilterChipWidget(
                  label: 'Tệp đính kèm',
                  value:
                      hasAttachments == true
                          ? 'Có'
                          : hasAttachments == false
                          ? 'Không'
                          : null,
                  onTap:
                      () => PickerBottomSheet.showAttachmentPicker(
                        context: context,
                        hasAttachments: hasAttachments,
                        onSelect: (value) {
                          setState(() => hasAttachments = value);
                          _updateFilters();
                        },
                      ),
                  onDeleted:
                      hasAttachments != null
                          ? () {
                            setState(() => hasAttachments = false);
                            _updateFilters();
                          }
                          : null,
                ),
                const SizedBox(width: 8),
                FilterChipWidget(
                  label: 'Ngày',
                  value:
                      selectedDateRange != null
                          ? AdvanceSearchUtils.formatDateRange(
                            selectedDateRange!,
                          )
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
