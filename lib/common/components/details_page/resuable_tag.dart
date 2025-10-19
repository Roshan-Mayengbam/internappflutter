import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:internappflutter/common/constants/details_page/reusable_tag_constants.dart';

class ReusableTag extends StatelessWidget {
  final String label;
  final TagStyle style;
  final bool isDottedBorder; // New flag for dotted styling

  const ReusableTag({
    super.key,
    required this.label,
    required this.style,
    this.isDottedBorder = false, // Defaults to false
  });

  // Builds the Box Decoration for the inner container
  BoxDecoration _buildInnerDecoration() {
    switch (style) {
      case TagStyle.statusPill:
        // If it uses DottedBorder, it just needs the background color (F9F3C6) and inner border radius.
        // DottedBorder handles the actual border.
        return BoxDecoration(
          color: TagStyles.statusPillBg,
          borderRadius: BorderRadius.circular(TagStyles.borderRadius),
        );
      case TagStyle.actionChip:
        // Action chip uses solid border/shadow
        return BoxDecoration(
          color: TagStyles.actionChipBg,
          borderRadius: BorderRadius.circular(TagStyles.borderRadius),
          boxShadow: [
            BoxShadow(
              color: TagStyles.actionChipShadowColor,
              offset: const Offset(2, 2),
            ),
          ],
        );
    }
  }

  // Builds the TextStyle based on the specified TagStyle
  TextStyle _buildTextStyle() {
    switch (style) {
      case TagStyle.statusPill:
        return TextStyle(
          fontFamily: TagStyles.fontFamily,
          fontSize: TagStyles.statusPillFontSize,
          color: TagStyles.statusPillFontColor,
          fontWeight: FontWeight.w500,
        );
      case TagStyle.actionChip:
        return TextStyle(
          fontFamily: TagStyles.fontFamily,
          fontSize: TagStyles.actionChipFontSize,
          color: TagStyles.actionChipFontColor,
          fontWeight: FontWeight.w500,
        );
    }
  }

  // Determines the leading checkmark icon
  Widget? _buildLeadingIcon() {
    if (style == TagStyle.statusPill) {
      return Padding(
        padding: const EdgeInsets.only(right: 6.0),
        child: Icon(
          Icons.check_circle_outline,
          color: TagStyles.statusPillFontColor,
          size: 16,
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final tagContent = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Optional leading icon
        _buildLeadingIcon() ?? const SizedBox.shrink(),

        // 2. The main label text
        Text(label, style: _buildTextStyle()),
      ],
    );

    // The inner container defines padding, background, and text styles
    final innerContainer = Container(
      decoration: _buildInnerDecoration(),
      padding: TagStyles.padding,
      child: tagContent,
    );

    Widget finalTag;
    if (style == TagStyle.statusPill && isDottedBorder) {
      finalTag = DottedBorder(
        options: RoundedRectDottedBorderOptions(
          padding: EdgeInsets.zero,
          color: TagStyles.statusPillBorder,
          strokeWidth: 1.0,
          dashPattern: const [4, 4],
          radius: Radius.circular(TagStyles.borderRadius),
        ),
        child: innerContainer,
      );
    } else {
      finalTag = innerContainer;
    }

    return finalTag;
  }
}
