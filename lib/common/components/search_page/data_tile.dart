import 'package:flutter/material.dart';
import '../../../features/core/design_systems/app_colors.dart';
import '../../../features/core/design_systems/app_typography.dart';
import '../../../features/core/design_systems/app_spacing.dart';
import '../../../features/core/design_systems/app_shapes.dart';

class DataTile extends StatelessWidget {
  final String title;
  final String description;
  final String? imageUrl;
  final VoidCallback onTap;

  const DataTile({
    super.key,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(color: AppColors.borderSoft, width: 2.0),
          borderRadius: AppShapes.card,
          boxShadow: const [
            BoxShadow(color: AppColors.shadowSharp, offset: Offset(4, 4)),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.primary.withOpacity(0.1),
          borderRadius: AppShapes.card,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLeadingContent(),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: (title.length > 25) ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.jobTitle,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.companyName,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingContent() {
    const double size = 50;
    final borderRadius = AppShapes.pill;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderSoft, width: 1.0),
          borderRadius: borderRadius,
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Image.network(
            imageUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: borderRadius,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder(size, borderRadius);
            },
          ),
        ),
      );
    } else {
      return _buildPlaceholder(size, borderRadius);
    }
  }

  Widget _buildPlaceholder(double size, BorderRadius borderRadius) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderSoft, width: 1.0),
        color: AppColors.primarySurface,
        borderRadius: borderRadius,
      ),
      child: const Icon(Icons.bookmark_border, color: AppColors.primary),
    );
  }
}
