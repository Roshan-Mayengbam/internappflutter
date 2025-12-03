import 'package:flutter/material.dart';
import 'package:internappflutter/features/core/design_systems/app_spacing.dart';
import 'package:internappflutter/features/core/design_systems/app_typography.dart';
import '../../../features/core/design_systems/app_colors.dart';
import '../../../features/core/design_systems/app_shapes.dart';
import 'filter_tag.dart';
import 'job_carousel_card.dart';
import 'package:lottie/lottie.dart';

// Reusable Custom Carousel Section
class CustomCarouselSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> filters;
  final String selectedFilter;
  final Function(String) onFilterTap;
  final bool statusPage;
  final bool isAppliedSection; // NEW: Flag to identify Applied Jobs section
  final List<Map<String, dynamic>> items;
  final VoidCallback? onViewMore;
  final Function(Map<String, dynamic>)? onItemTap;

  const CustomCarouselSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterTap,
    required this.items,
    this.statusPage = false,
    this.isAppliedSection = false,
    this.onViewMore,
    this.onItemTap,
    required Null Function(String p1) onCarouselTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(title, style: AppTypography.headingLg),
          const SizedBox(height: 4),
          // Subtitle
          Text(subtitle, style: AppTypography.bodySm.copyWith(fontSize: 14)),

          if (onViewMore != null && items.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onViewMore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentLime,
                  foregroundColor: AppColors.card,
                  shape: RoundedRectangleBorder(borderRadius: AppShapes.pill),
                  side: BorderSide(color: AppColors.borderStrong),
                  elevation: 4,
                  shadowColor: AppColors.shadowSoft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                ),
                child: Text(
                  "View More",
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 12,
                    color: AppColors.borderStrong,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Filters
          (filters.isNotEmpty)
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filters.map((filter) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterTag(
                          label: filter,
                          isSelected: selectedFilter == filter,
                          onTap: () => onFilterTap(filter),
                        ),
                      );
                    }).toList(),
                  ),
                )
              : Container(),

          const SizedBox(height: 16),

          // Carousel or Empty State
          items.isEmpty
              ? Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 80,
                      horizontal: 20,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'assets/animations/empty/empty_lottie.json',
                          width: 200,
                          height: 200,
                          repeat: false,
                          animate: true,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          subtitle.toLowerCase().contains('saved')
                              ? 'No saved jobs yet'
                              : 'No applied jobs yet',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontFamily: 'jost',
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: GestureDetector(
                          onTap: () {
                            if (onItemTap != null) {
                              onItemTap!(item);
                            }
                          },
                          child: CarouselCard(
                            title: item["jobTitle"],
                            subtitle: item["companyName"],
                            tag1: statusPage
                                ? (isAppliedSection
                                      ? (item["applicationStatus"] ?? "Applied")
                                      : (item["applied"] ?? false)
                                      ? "Applied"
                                      : "Not Applied")
                                : item["location"], // For Job/Hackathon pages, show location
                            tag2: isAppliedSection
                                ? null // No second tag for Applied section
                                : item['experienceLevel'],
                            statusCard:
                                isAppliedSection, // Single tag mode for applied
                            location: item["location"],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
