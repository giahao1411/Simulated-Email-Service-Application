import 'package:flutter/material.dart';
import 'package:email_application/features/email/models/search_filters.dart';
import 'package:email_application/features/email/views/widgets/search_app_bar.dart';
import 'package:email_application/features/email/views/widgets/search_results.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({required this.currentCategory, super.key});

  final String currentCategory;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = '';
  SearchFilters _filters = const SearchFilters();
  bool _hasSearched = false;

  void _onSearchChanged(String query) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _searchQuery = query;
        _hasSearched = query.isNotEmpty || _filters.hasActiveFilters;
      });
    });
  }

  void _onSearchSubmitted(String query) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _searchQuery = query;
        _hasSearched = query.isNotEmpty || _filters.hasActiveFilters;
      });
    });
  }

  void _onFiltersChanged(SearchFilters filters) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _filters = filters;
        _hasSearched = _searchQuery.isNotEmpty || filters.hasActiveFilters;
      });
    });
  }

  void _onBackPressed() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SearchAppBar(
              currentCategory: widget.currentCategory,
              onSearchChanged: _onSearchChanged,
              onSearchSubmitted: _onSearchSubmitted,
              onBackPressed: _onBackPressed,
              onFiltersChanged: _onFiltersChanged,
            ),
            Expanded(
              child:
                  _hasSearched
                      ? SearchResults(
                        searchQuery: _searchQuery,
                        currentCategory: widget.currentCategory,
                        filters: _filters,
                      )
                      : _buildInitialState(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white70 : Colors.grey[600];
    final iconColor = isDarkMode ? Colors.white38 : Colors.grey[400];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: iconColor),
          const SizedBox(height: 24),
          Text(
            'Tìm trong thư',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Nhập từ khóa hoặc sử dụng bộ lọc để tìm kiếm email',
              style: TextStyle(color: textColor, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
