import 'package:flutter/material.dart';

import 'package:internappflutter/common/constants/filter_tag_constants.dart';

class FilterTag extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterTag({
    super.key,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Apply tap only if applicable
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: FilterTagConstants.border,
          borderRadius: FilterTagConstants.borderRadius,
        ),
        child: Container(
          padding: FilterTagConstants.padding,
          decoration: BoxDecoration(
            color: isSelected
                ? FilterTagConstants.selectedBg
                : FilterTagConstants.unselectedBg,
            borderRadius: FilterTagConstants.borderRadius,
          ),
          child: Text(label, style: FilterTagConstants.filterText),
        ),
      ),
    );
  }
}
