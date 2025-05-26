import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_application/features/email/providers/theme_manage.dart';
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
  bool _isSearching = false;

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });
  }

  void _onSearchSubmitted(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });
    print('Đang tìm kiếm: $query');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeManage>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final iconColor = isDarkMode ? Colors.white38 : Colors.grey;
    final textColor = isDarkMode ? Colors.white70 : Colors.grey;

    return Scaffold(
      backgroundColor: surfaceColor,
      body: SafeArea(
        child: Column(
          children: [
            SearchAppBar(
              onSearchChanged: _onSearchChanged,
              onSearchSubmitted: _onSearchSubmitted,
              onBackPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child:
                  _isSearching
                      ? SearchResults(
                        searchQuery: _searchQuery,
                        currentCategory: widget.currentCategory,
                      )
                      : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, size: 64, color: iconColor),
                            const SizedBox(height: 16),
                            Text(
                              'Nhập từ khóa để tìm kiếm trong thư',
                              style: TextStyle(color: textColor, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
