import 'package:flutter/material.dart';
import 'package:internappflutter/features/domain/entities/job_response.dart';

import '../filter_tag.dart';
import 'carousel_card.dart';

// Reusable Custom Carousel Section
class CustomCarouselSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> filters;
  final String selectedFilter;
  final Function(String) onFilterTap;
  final bool statusPage;
  final List<Job> items; // This remains the same
  final VoidCallback? onViewMore;

  const CustomCarouselSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterTap,
    required this.items,
    this.statusPage = false,
    this.onViewMore,
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

          if (onViewMore != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onViewMore,
                child: const Text(
                  "View More",
                  style: TextStyle(
                    fontSize: 14, // slightly larger
                    fontWeight: FontWeight.w600,
                    color: Colors.black, // black text
                    decoration: TextDecoration.underline, // underline
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

          const SizedBox(height: 20),
          // Carousel
          SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) {
                // --- PARSING LOGIC IS IMPLEMENTED HERE ---
                final job = items[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: CarouselCard(
                    title: job.title,
                    subtitle: job.recruiter.company.name,
                    tag1: job.location ?? 'N/A',
                    tag2: job.recruiter.company.companyType ?? 'Startup',
                    isVerified: job.recruiter.isVerified,
                    statusCard: statusPage,
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
