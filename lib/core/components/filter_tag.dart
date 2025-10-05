import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

import 'package:internappflutter/core/constants/filter_tag_constants.dart';

class FilterTag extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDashed;
  final bool isTappable;
  final VoidCallback? onTap;

  const FilterTag({
    super.key,
    required this.label,
    this.isSelected = false,
    this.isDashed = false,
    this.isTappable = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Common content: text + background color
    final child = Container(
      padding: FilterTagConstants.padding,
      decoration: BoxDecoration(
        color: isDashed
            ? FilterTagConstants.dashedBg
            : (isSelected
                  ? FilterTagConstants.selectedBg
                  : FilterTagConstants.unselectedBg),
        borderRadius: FilterTagConstants.borderRadius,
      ),
      child: Text(
        label,
        style: isDashed
            ? FilterTagConstants.dashedText
            : FilterTagConstants.filterText,
      ),
    );

    // Choose wrapper based on type
    Widget tag = isDashed
        ? DottedBorder(child: child)
        : Container(
            decoration: BoxDecoration(
              border: FilterTagConstants.border,
              borderRadius: FilterTagConstants.borderRadius,
            ),
            child: child,
          );

    // Apply tap only if applicable
    return isTappable && onTap != null
        ? GestureDetector(onTap: onTap, child: tag)
        : tag;
  }
}
