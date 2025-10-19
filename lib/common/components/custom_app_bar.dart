import 'package:flutter/material.dart';
import 'custom_button.dart';
import 'custom_search_field.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
    required this.searchController,
    required this.onSearchSubmit,
    required this.onChatPressed,
    required this.onNotificationPressed,
  });

  final TextEditingController searchController;
  final void Function(String) onSearchSubmit;
  final VoidCallback onChatPressed;
  final VoidCallback onNotificationPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: CustomSearchField(
                controller: searchController,
                onSubmitted: onSearchSubmit,
                foregroundColor: Colors.white,
                backgroundColor: Colors.black,
                hintText: 'Search jobs',
              ),
            ),
          ),
          const SizedBox(width: 10),
          CustomButton(
            buttonIcon: Icons.chat_bubble_outline,
            onPressed: onChatPressed,
          ),
          const SizedBox(width: 10),
          CustomButton(
            buttonIcon: Icons.notifications_none,
            onPressed: onNotificationPressed,
          ),
        ],
      ),
    );
  }
}
