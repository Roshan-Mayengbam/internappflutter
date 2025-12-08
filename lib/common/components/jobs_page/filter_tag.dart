// core/widgets/filter_tag.dart
import 'package:flutter/material.dart';

import '../../../features/core/design_systems/app_colors.dart';
import '../../../features/core/design_systems/app_shapes.dart';
import '../../../features/core/design_systems/app_typography.dart';

class FilterTag extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterTag({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentLime : Colors.white,
          borderRadius: AppShapes.pill,
          border: Border.all(color: AppColors.borderStrong, width: 1.2),
        ),
        child: Text(label, style: AppTypography.chip),
      ),
    );
  }
}
