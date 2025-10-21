import 'package:flutter/material.dart';
import 'package:internappflutter/common/components/jobs_page/filter_tag.dart';
import '../../constants/search_page/search_page_constants.dart';

class SearchFilterGroup extends StatelessWidget {
  final SearchCategory selectedFilter;
  final ValueChanged<SearchCategory> onFilterSelected;

  const SearchFilterGroup({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45, // Fixed height for horizontal scrolling
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        scrollDirection: Axis.horizontal,
        itemCount: kSearchFilters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8.0),

        itemBuilder: (context, index) {
          final filter = kSearchFilters[index];

          return FilterTag(
            // Use the label from the FilterCategory object
            label: filter.label,
            // Compare the current filter object with the selected one
            isSelected: filter == selectedFilter,
            // Execute the callback with the selected filter object
            onTap: () => onFilterSelected(filter),
          );
        },
      ),
    );
  }
}
