import 'package:flutter/material.dart';
import 'package:internappflutter/core/components/jobs_page/job_carousel_card.dart';

class ViewMores extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final bool statusPage;
  final bool isAppliedSection; // NEW: Add this parameter

  const ViewMores({
    super.key,
    required this.items,
    required this.statusPage,
    this.isAppliedSection = false, // NEW: Default to false
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAppliedSection
              ? 'Applied Jobs'
              : statusPage
              ? 'Saved Jobs'
              : 'All Jobs',
          style: const TextStyle(fontFamily: 'jost'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.work_outline,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No jobs found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontFamily: 'jost',
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1, // Single column for better mobile view
                    childAspectRatio: 1.5, // Adjust card height
                    mainAxisSpacing: 16,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    return CarouselCard(
                      title: item["jobTitle"] ?? "Unknown Job",
                      subtitle: item["companyName"] ?? "Unknown Company",
                      location: item["location"],
                      // ✅ Same logic as custom_carousel_section.dart
                      tag1: statusPage
                          ? (isAppliedSection
                                ? (item["applicationStatus"] ?? "Applied")
                                : (item["applied"] ?? false)
                                ? "Applied"
                                : "Not Applied")
                          : item["location"] ?? "Location N/A",
                      tag2: isAppliedSection
                          ? null // No second tag for Applied section
                          : item['experienceLevel'] ?? "Entry level",
                      statusCard:
                          isAppliedSection, // Single tag mode for applied
                    );
                  },
                ),
        ),
      ),
    );
  }
}
