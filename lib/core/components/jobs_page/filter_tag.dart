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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: FilterTagConstants.padding,
        decoration: BoxDecoration(
          gradient: widget.isSelected
              ? FilterTagConstants.selectedGradient
              : null,
          color: widget.isSelected ? null : FilterTagConstants.unselectedBg,
          borderRadius: BorderRadius.circular(FilterTagConstants.borderRadius),
          boxShadow: widget.isSelected
              ? FilterTagConstants.selectedShadow
              : FilterTagConstants.unselectedShadow,
          border: widget.isSelected
              ? null
              : FilterTagConstants.unselectedBorder,
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            fontSize: FilterTagConstants.fontSize,
            fontWeight: FilterTagConstants.fontWeight,
            fontFamily: FilterTagConstants.fontFamily,
            color: widget.isSelected
                ? Colors.white
                : FilterTagConstants.unselectedText,
          ),
        ),
      ),
    );
  }
}
