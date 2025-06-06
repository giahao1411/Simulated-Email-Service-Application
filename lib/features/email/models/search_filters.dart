import 'package:flutter/material.dart';

@immutable
class SearchFilters {
  const SearchFilters({
    this.category, // Danh mục từ drawer (Inbox, Sent, Draft, etc.)
    this.from,
    this.to,
    this.hasAttachments,
    this.dateRange,
  });

  final String? category;
  final String? from;
  final String? to;
  final bool? hasAttachments;
  final DateTimeRange? dateRange;

  bool get hasActiveFilters =>
      category != null ||
      from != null ||
      to != null ||
      hasAttachments != null ||
      dateRange != null;

  SearchFilters copyWith({
    String? category,
    String? from,
    String? to,
    bool? hasAttachments,
    DateTimeRange? dateRange,
  }) {
    return SearchFilters(
      category: category ?? this.category,
      from: from ?? this.from,
      to: to ?? this.to,
      hasAttachments: hasAttachments ?? this.hasAttachments,
      dateRange: dateRange ?? this.dateRange,
    );
  }

  @override
  String toString() {
    return '''SearchFilters(category: $category, from: $from, to: $to, hasAttachments: $hasAttachments, dateRange: $dateRange)''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchFilters &&
        other.category == category &&
        other.from == from &&
        other.to == to &&
        other.hasAttachments == hasAttachments &&
        other.dateRange == dateRange;
  }

  @override
  int get hashCode {
    return category.hashCode ^
        from.hashCode ^
        to.hashCode ^
        hasAttachments.hashCode ^
        dateRange.hashCode;
  }
}
