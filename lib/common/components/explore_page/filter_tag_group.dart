// lib/presentation/widgets/organisms/filter_tag_group.dart (UPDATED)

import 'package:flutter/material.dart';

import 'package:internappflutter/common/constants/explore_page/explore_page_constant.dart';
import 'package:internappflutter/common/components/jobs_page/filter_tag.dart';

class FilterTagGroup extends StatelessWidget {
  // Change type from String to the ExploreFilter enum
  final ExploreFilter selectedFilter;
  final Function(ExploreFilter) onFilterSelected; // Change callback signature

  const FilterTagGroup({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        scrollDirection: Axis.horizontal,
        itemCount: kVisibleExploreFilters.length, // Use the constant list
        separatorBuilder: (context, index) => const SizedBox(width: 8.0),
        itemBuilder: (context, index) {
          final filter = kVisibleExploreFilters[index];
          return FilterTag(
            label: filter.label, // Use the enum's label property
            // Compare enums directly
            isSelected: filter == selectedFilter,
            onTap: () => onFilterSelected(filter),
          );
        },
      ),
    );
  }
}
