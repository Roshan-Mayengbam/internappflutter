import 'package:flutter/material.dart';
import 'filter_tag.dart';
import 'job_carousel_card.dart';

// Reusable Custom Carousel Section
class CustomCarouselSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> filters;
  final String selectedFilter;
  final Function(String) onFilterTap;
  final bool statusPage;
  final bool isAppliedSection;
  final bool isHackathonPage; // Changed from final with default value
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
    this.isHackathonPage = false, // Add default value here
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'jost',
            ),
          ),
          const SizedBox(height: 4),

          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontFamily: "jost",
            ),
          ),

          if (onViewMore != null && items.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onViewMore,
                child: const Text(
                  "View More",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    decoration: TextDecoration.underline,
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
                        Icon(
                          isHackathonPage
                              ? Icons.emoji_events_outlined
                              : subtitle.toLowerCase().contains('saved')
                              ? Icons.bookmark_border
                              : Icons.work_outline,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          isHackathonPage
                              ? 'No hackathons available'
                              : subtitle.toLowerCase().contains('saved')
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
                  height: 300,
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
                                : item["location"],
                            tag2: isAppliedSection
                                ? null
                                : item['experienceLevel'],
                            statusCard: isAppliedSection,
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
