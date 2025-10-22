import 'package:flutter/material.dart';
import '../common/components/details_page/resuable_tag.dart';
import '../common/constants/details_page/reusable_tag_constants.dart';

class DescriptionScreen extends StatelessWidget {
  const DescriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: [
          ReusableTag(
            label: 'On-Site',
            style: TagStyle.statusPill,
            isDottedBorder: true,
          ),
          ReusableTag(label: 'Adobe', style: TagStyle.actionChip),
        ],
      ),
    );
  }
}
