import 'package:flutter/material.dart';
import 'package:internappflutter/core/constants/search_field_constants.dart';

class CustomSearchField extends StatelessWidget {
  const CustomSearchField({
    super.key,
    this.foregroundColor = Colors.white,
    this.backgroundColor = Colors.black,
    this.hintText = 'Search jobs',
    this.onTap,
    this.controller,
    this.onSubmitted,
  });

  final Color foregroundColor;
  final Color backgroundColor;
  final String hintText;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final void Function(String)? onSubmitted; // Keyboard submit

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
            Expanded(
              child: TextField(
                controller: controller,
                onSubmitted: onSubmitted,
                style: TextStyle(
                  fontFamily: 'jost',
                  color: backgroundColor,
                  fontSize: SearchFieldConstants.fontSize,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: backgroundColor.withOpacity(0.7),
                    fontSize: SearchFieldConstants.fontSize,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
