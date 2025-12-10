import 'package:flutter/material.dart';
// Note: Removed unused import 'package:internappflutter/features/screens/search_page/search_page.dart';
import 'custom_button.dart';
import 'custom_search_field.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
    required this.onChatPressed,
    required this.onNotificationPressed,

    // Search fields made nullable, required pairings enforced via assert
    this.searchController,
    this.onSearchSubmit,
    this.onTap,
  });

  final TextEditingController? searchController;
  final void Function(String)? onSearchSubmit; // Now nullable in the class
  final VoidCallback? onTap; // Optional tap handler

  final VoidCallback onChatPressed;
  final VoidCallback onNotificationPressed;

  @override
  Widget build(BuildContext context) {
    // Determine which mode we are in based on the presence of the controller
    final bool isEditable = searchController != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: CustomSearchField(
                // Pass controller unconditionally (may be null)
                controller: searchController,

                onSubmitted: isEditable ? onSearchSubmit : null,

                onTap: isEditable ? null : onTap,

                // Style properties
                foregroundColor: Colors.white,
                backgroundColor: Colors.black,
                hintText: 'Search',
              ),
            ),
          ),
          const SizedBox(width: 10),
          CustomButton(
            buttonIcon: Icons.chat_bubble_outline,
            onPressed: onChatPressed,
          ),
          const SizedBox(width: 10),
          // CustomButton(
          //   buttonIcon: Icons.notifications_none,
          //   onPressed: onNotificationPressed,
          // ),
        ],
      ),
    );
  }
}
