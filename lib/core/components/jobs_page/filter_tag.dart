import 'package:flutter/material.dart';
import 'package:internappflutter/core/constants/filter_tag_constants.dart';

class FilterTag extends StatefulWidget {
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
  State<FilterTag> createState() => _FilterTagState();
}

class _FilterTagState extends State<FilterTag> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: FilterTagConstants.padding,
        decoration: BoxDecoration(
          color: widget.isSelected
              ? FilterTagConstants.selectedBg
              : FilterTagConstants.unselectedBg,
          border: FilterTagConstants.border,
          borderRadius: FilterTagConstants.borderRadius,
        ),
        child: Text(widget.label, style: FilterTagConstants.filterText),
      ),
    );
  }
}
