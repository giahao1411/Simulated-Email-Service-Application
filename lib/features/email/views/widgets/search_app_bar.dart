import 'package:flutter/material.dart';
import 'package:email_application/features/email/models/search_filters.dart';
import 'package:email_application/features/email/views/widgets/advanced_search_filters.dart';

class SearchAppBar extends StatefulWidget {
  const SearchAppBar({
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.onBackPressed,
    required this.onFiltersChanged,
    super.key,
  });

  final void Function(String) onSearchChanged;
  final void Function(String) onSearchSubmitted;
  final VoidCallback onBackPressed;
  final void Function(SearchFilters) onFiltersChanged;

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
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final hintTextColor = Theme.of(
      context,
    ).colorScheme.onSurface.withOpacity(0.6);
    final iconColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);

    return Container(
      color: surfaceColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: iconColor,
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
                    icon: const Icon(Icons.close),
                    color: iconColor,
                    onPressed: () {
                      _controller.clear();
                      widget.onSearchChanged('');
                      FocusScope.of(context).requestFocus(_focusNode);
                    },
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.mic),
                    color: iconColor,
                    onPressed: () {
                      print('Voice search pressed');
                    },
                  ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          AdvancedSearchFilters(onFiltersChanged: widget.onFiltersChanged),
        ],
      ),
    );
  }
}
