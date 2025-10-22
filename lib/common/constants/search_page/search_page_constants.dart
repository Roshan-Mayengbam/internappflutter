import 'package:flutter/material.dart';

class SearchCategory {
  final String label;
  final String searchFilter; // The slug or API parameter for this filter
  final IconData icon;

  const SearchCategory({
    required this.label,
    required this.searchFilter,
    required this.icon,
  });
}

enum SearchScope { jobs, hackathons, companies }

final List<SearchCategory> kSearchFilters = [
  const SearchCategory(label: 'Jobs', searchFilter: 'jobs', icon: Icons.work),
  const SearchCategory(
    label: 'Hackathons',
    searchFilter: 'hackathons',
    icon: Icons.schedule,
  ),
  const SearchCategory(
    label: 'Companies',
    searchFilter: 'companies',
    icon: Icons.person_add,
  ),
];
