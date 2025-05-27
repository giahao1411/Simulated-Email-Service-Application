import 'package:flutter/material.dart';

class SearchFilters {
  const SearchFilters({
    this.label,
    this.from,
    this.to,
    this.hasAttachments,
    this.dateRange,
  });

  final String? label;
  final String? from;
  final String? to;
  final bool? hasAttachments;
  final DateTimeRange? dateRange;

  bool get hasActiveFilters =>
      label != null ||
      from != null ||
      to != null ||
      hasAttachments != null ||
      dateRange != null;

  SearchFilters copyWith({
    String? label,
    String? from,
    String? to,
    bool? hasAttachments,
    DateTimeRange? dateRange,
  }) {
    return SearchFilters(
      label: label ?? this.label,
      from: from ?? this.from,
      to: to ?? this.to,
      hasAttachments: hasAttachments ?? this.hasAttachments,
      dateRange: dateRange ?? this.dateRange,
    );
  }
}
