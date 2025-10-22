import 'package:flutter/material.dart';
import 'package:internappflutter/common/components/custom_button.dart';
import 'package:internappflutter/common/components/custom_search_field.dart';

class SearchPageAppBar extends StatelessWidget {
  const SearchPageAppBar({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final void Function(String) onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Back Button
          CustomButton(
            buttonIcon: Icons.arrow_back,
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          const SizedBox(width: 25),

          // 2. Custom Search Field
          Expanded(
            child: CustomSearchField(
              // Added key for better testing and widget tree management
              key: const ValueKey('SearchPageAppBar_SearchField'),
              controller: controller,
              onSubmitted: onSubmitted,
            ),
          ),
        ],
      ),
    );
  }
}
