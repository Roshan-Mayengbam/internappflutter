import 'package:flutter/material.dart';
import 'package:internappflutter/features/core/design_systems/app_typography.dart';

import '../../../features/core/design_systems/app_colors.dart';
import '../../../features/core/design_systems/app_shapes.dart';
import '../../../features/core/design_systems/app_spacing.dart';

class CarouselCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? tag1;
  final String? tag2;
  final bool statusCard;
  final bool isVerified;
  final VoidCallback? onTap;

  const CarouselCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.tag1,
    this.tag2,
    this.statusCard = true,
    this.isVerified = false,
    this.onTap,
    required location,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 320,
        margin: const EdgeInsets.only(
          right: AppSpacing.lg,
        ), // Standard margin for carousel
        padding: const EdgeInsets.all(AppSpacing.md), // Reduced main padding
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(
            color: AppColors.borderStrong,
            width: 1.0,
          ), // Use soft border
          borderRadius: AppShapes.card, // Use radiusLg (20) from AppShapes
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowSoft,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // ✅ Prevent overflow
          children: [
            // Banner
            // Banner
            ClipRRect(
              borderRadius:
                  AppShapes.pill, // Using AppShapes for consistent radius
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage(
                      'assets/images/job_card/banner_background.png',
                    ),
                    fit: BoxFit.fill,
                    alignment: Alignment.center,
                  ),
                  gradient: AppColors.bannerGradient,
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ), // Use AppSpacing
                  child: Text(
                    title,
                    style: AppTypography.headingLg.copyWith(
                      color: AppColors.card,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg), // ✅ Reduced from 16
            // Row with two columns
            Flexible(
              // ✅ Make this flexible to prevent overflow
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Title + Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: AppTypography.jobTitle.copyWith(height: 1.2),
                          maxLines: (title.length > 18) ? 2 : 1,
                        ),
                        const SizedBox(
                          height: AppSpacing.sm,
                        ), // ✅ Reduced from 6
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                subtitle,
                                style: AppTypography.companyName.copyWith(
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            if (isVerified) ...[
                              const SizedBox(width: AppSpacing.xs),
                              const Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 16,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Right: Tags
                  SizedBox(
                    width: 100,
                    child: statusCard || tag2 == null
                        ? (tag1 != null ? buildTag(tag1!) : const SizedBox())
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (tag1 != null) buildTag(tag1!),
                              if (tag1 != null && tag2 != null)
                                const SizedBox(
                                  height: AppSpacing.md,
                                ), // ✅ Reduced from 6
                              if (tag2 != null) buildTag(tag2!),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTag(String label) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: AppShapes.pill,
        border: Border.all(color: AppColors.borderStrong, width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.chip.copyWith(
              color: AppColors.primary,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }
}
