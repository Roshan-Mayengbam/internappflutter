import 'package:flutter/material.dart';
import 'package:internappflutter/common/constants/search_field_constants.dart';

import '../../features/screens/search_page/search_page.dart';
// Note: Assuming GlobalSearchPage is the target page for navigation

class CustomSearchField extends StatelessWidget {
  const CustomSearchField({
    super.key,
    this.foregroundColor = Colors.white,
    this.backgroundColor = Colors.black,
    this.hintText = 'Search jobs',
    this.onTap, // Optional tap handler
    this.controller, // Optional controller
    this.onSubmitted, // Optional submit handler
  }) : assert(
         !(controller != null &&
                 onTap != null) && // Cannot be both input and tap mode
             !(controller == null &&
                 onSubmitted != null), // Cannot have submit without controller

         'CustomSearchField configuration error: \n'
         '1. For Editable Input: Provide (controller, onSubmitted) and set (onTap) to null. \n'
         '2. For Tappable/Navigation: Provide (onTap) and set (controller, onSubmitted) to null.',
       );

  final Color foregroundColor;
  final Color backgroundColor;
  final String hintText;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final void Function(String)? onSubmitted; // Keyboard submit

  // Default navigation function to be used if no configuration is provided
  void _defaultNavigateToSearch(BuildContext context) {
    // Navigate to the full search page
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SearchPage()));
  }

  @override
  Widget build(BuildContext context) {
    // 1. Check the condition: Is a controller provided?
    final bool isEditable = controller != null;

    // 2. Determine the effective onTap handler.
    // If NOT editable AND the explicit onTap is null, use the default navigation.
    final VoidCallback effectiveOnTap = !isEditable && onTap == null
        ? () => _defaultNavigateToSearch(context)
        : onTap ??
              () {}; // Use explicit onTap or an empty function if editable but onTap is somehow checked.

    // 3. Define the content (Icon + Text/TextField)
    Widget content = Row(
      children: [
        Icon(
          Icons.search,
          color: backgroundColor,
          size: SearchFieldConstants.iconSize,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: isEditable
              ? TextField(
                  // --- Editable Input Field ---
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
                )
              : Text(
                  // --- Read-Only Text/Placeholder for Tap Mode ---
                  hintText,
                  style: TextStyle(
                    fontFamily: 'jost',
                    color: backgroundColor.withOpacity(0.7),
                    fontSize: SearchFieldConstants.fontSize,
                  ),
                ),
        ),
      ],
    );

    // 4. Apply the correct wrapper based on the condition
    if (isEditable) {
      // If controller is provided, return the container directly.
      return _buildSearchContainer(child: content);
    } else {
      // If NO controller is provided, wrap with a GestureDetector using the effectiveOnTap.
      return GestureDetector(
        onTap: effectiveOnTap, // Use the handler which defaults to navigation
        child: _buildSearchContainer(child: content),
      );
    }
  }

  // Helper method to create the consistent decorative container
  Widget _buildSearchContainer({required Widget child}) {
    // ... (Container decoration code remains the same)
    return Container(
      height: SearchFieldConstants.height,
      padding: const EdgeInsets.symmetric(
        horizontal: SearchFieldConstants.horizontalPadding,
        vertical: SearchFieldConstants.verticalPadding,
      ),
      decoration: BoxDecoration(
        color: foregroundColor,
        borderRadius: BorderRadius.circular(SearchFieldConstants.borderRadius),
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
      child: child,
    );
  }
}
