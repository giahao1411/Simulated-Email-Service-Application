import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/features/email/models/search_filters.dart';
import 'package:email_application/features/email/providers/theme_manage.dart';
import 'package:email_application/features/email/views/widgets/advanced_search_filters.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchAppBar extends StatefulWidget {
  const SearchAppBar({
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.onBackPressed,
    required this.onFiltersChanged,
    required this.currentCategory,
    super.key,
  });

  final void Function(String) onSearchChanged;
  final void Function(String) onSearchSubmitted;
  final VoidCallback onBackPressed;
  final void Function(SearchFilters) onFiltersChanged;
  final String currentCategory;

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    });

    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _requestFocus() {
    FocusScope.of(context).requestFocus(_focusNode);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeManage>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final hintTextColor = Theme.of(
      context,
    ).colorScheme.onSurface.withOpacity(0.6);
    final iconColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    final dividerColor = isDarkMode ? Colors.grey[600] : Colors.grey[300];

    return ColoredBox(
      color: surfaceColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: iconColor),
                  onPressed: widget.onBackPressed,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.search,
                    enableInteractiveSelection: true,
                    showCursor: true,
                    style: TextStyle(color: textColor, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Tìm trong thư',
                      hintStyle: TextStyle(color: hintTextColor, fontSize: 16),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: surfaceColor,
                    ),
                    onChanged: widget.onSearchChanged,
                    onSubmitted: widget.onSearchSubmitted,
                    onTap: _requestFocus,
                  ),
                ),
                if (_controller.text.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.close, color: iconColor),
                    onPressed: () {
                      _controller.clear();
                      widget.onSearchChanged('');
                      FocusScope.of(context).requestFocus(_focusNode);
                    },
                  )
                else
                  IconButton(
                    icon: Icon(Icons.mic, color: iconColor),
                    onPressed: () {
                      AppFunctions.debugPrint('Voice search pressed');
                    },
                  ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 0.5, color: dividerColor),
          AdvancedSearchFilters(
            onFiltersChanged: widget.onFiltersChanged,
            currentCategory: widget.currentCategory,
          ),
        ],
      ),
    );
  }
}
