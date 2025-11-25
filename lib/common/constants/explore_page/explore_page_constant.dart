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
// lib/common/nts/explore_page_nts.dart

List<ExploreFilter> kVisibleExploreFilters = [
  ExploreFilter(
    label: 'Software Development',
    searchFilter: '"software development" OR "apps" OR "application"',
    icon: Icons.code,
  ),
  ExploreFilter(
    label: 'All Technology',
    searchFilter: 'technology',
    icon: Icons.public,
  ),
  ExploreFilter(
    label: 'Science & Research',
    searchFilter: 'science OR research',
    icon: Icons.biotech,
  ),
  ExploreFilter(
    label: 'Business & Jobs',
    searchFilter: 'business OR careers OR jobs',
    icon: Icons.work,
  ),
  ExploreFilter(
    label: 'Internet & Web',
    searchFilter: 'internet OR instagram OR meta OR X OR twitter OR facebook',
    icon: Icons.language,
  ),
  ExploreFilter(
    label: 'AI & ML',
    searchFilter: 'ai OR ml OR "machine learning"',
    icon: Icons.smart_toy,
  ),
  ExploreFilter(
    label: 'Programming Languages',
    searchFilter: 'python OR javascript OR rust OR go',
    icon: Icons.data_object,
  ),
  ExploreFilter(
    label: 'Data Science & Analytics',
    searchFilter: '"data science" OR "big data" OR analytics',
    icon: Icons.query_stats,
  ),
  ExploreFilter(
    label: 'Cybersecurity',
    searchFilter: 'cybersecurity OR hacking OR "data breach"',
    icon: Icons.security,
  ),
  ExploreFilter(
    label: 'Startup Ecosystem',
    searchFilter: 'startup OR "venture capital" OR entrepreneurship',
    icon: Icons.rocket_launch,
  ),
  ExploreFilter(
    label: 'Remote Work',
    searchFilter: '"remote work" OR wfh OR "work from home"',
    icon: Icons.wifi,
  ),
  ExploreFilter(
    label: 'Future of Work',
    searchFilter: '"future of work" OR automation OR upskilling',
    icon: Icons.trending_up,
  ),
];
