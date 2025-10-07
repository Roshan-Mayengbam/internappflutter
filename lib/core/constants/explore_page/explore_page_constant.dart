import 'package:flutter/material.dart';

/// A class to hold the display label and the corresponding API search filter/tag.
class ExploreFilter {
  final String label;
  final String searchFilter;
  final IconData icon; // Optional: Added for richer UI later

  ExploreFilter({
    required this.label,
    required this.searchFilter,
    required this.icon,
  });

  // Equality check for comparing selected filter in ViewModel
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExploreFilter &&
          runtimeType == other.runtimeType &&
          label == other.label;

  @override
  int get hashCode => label.hashCode;
}

// --- Common Tech-Related Filter Tags ---
// lib/core/nts/explore_page_nts.dart

List<ExploreFilter> kVisibleExploreFilters = [
  ExploreFilter(
    label: 'All Technology',
    searchFilter: 'technology',
    icon: Icons.public,
  ),
  ExploreFilter(
    label: 'Science & Research',
    searchFilter: 'science',
    icon: Icons.biotech,
  ),
  ExploreFilter(
    label: 'Business & Jobs',
    searchFilter: 'business|careers|jobs', // Job Market
    icon: Icons.work,
  ),
  ExploreFilter(
    label: 'Internet & Web',
    searchFilter: 'technology/internet', // New: Specific section tag
    icon: Icons.language,
  ),
  ExploreFilter(
    label: 'Social Media',
    searchFilter: 'technology/social', // New: Specific section tag
    icon: Icons.people,
  ),
  ExploreFilter(
    label: 'Software Development',
    searchFilter: 'technology/software', // New: Developer-focused search
    icon: Icons.code,
  ),
  ExploreFilter(
    label: 'AI & ML',
    searchFilter: 'technology/artificial-intelligence',
    icon: Icons.smart_toy,
  ),
];
