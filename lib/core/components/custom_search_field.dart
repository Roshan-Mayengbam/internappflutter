import 'package:flutter/material.dart';

import 'package:internappflutter/core/constants/search_field_constants.dart';

class CustomSearchField extends StatelessWidget {
  const CustomSearchField({
    super.key,
    this.foregroundColor = Colors.white, // A light purple
    this.backgroundColor = Colors.black, // Now used for border and icon
    this.hintText = 'Search jobs',
    this.onTap,
  });

  final Color foregroundColor;
  final Color backgroundColor;
  final String hintText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: SearchFieldConstants.height,
        padding: const EdgeInsets.symmetric(
          horizontal: SearchFieldConstants.horizontalPadding,
          vertical: SearchFieldConstants.verticalPadding,
        ),
        decoration: BoxDecoration(
          color: foregroundColor,
          borderRadius: BorderRadius.circular(
            SearchFieldConstants.borderRadius,
          ),
          border: Border.all(
            color: backgroundColor,
            width: SearchFieldConstants.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.7),
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: backgroundColor,
              size: SearchFieldConstants.iconSize,
            ),
            const SizedBox(width: 8),
            Text(
              hintText,
              style: TextStyle(
                color: backgroundColor,
                fontSize: SearchFieldConstants.fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
