import 'package:flutter/material.dart';

import 'package:internappflutter/core/constants/job_carousel_card_constants.dart';

class JobCarouselCard extends StatelessWidget {
  final String jobTitle;
  final String companyName;
  final String location;
  final String experienceLevel;

  const JobCarouselCard({
    super.key,
    required this.jobTitle,
    required this.companyName,
    required this.location,
    required this.experienceLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: JobCardConstants.margin,
      padding: JobCardConstants.padding,
      decoration: BoxDecoration(
        color: Colors.white,
        border: JobCardConstants.cardBorder,
        borderRadius: BorderRadius.circular(JobCardConstants.borderRadius),
        boxShadow: JobCardConstants.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 140,
              decoration: const BoxDecoration(
                gradient: JobCardConstants.bannerGradient,
              ),
              alignment: Alignment.center,
              child: Text(jobTitle, style: JobCardConstants.bannerTextStyle),
            ),
          ),
          const SizedBox(height: 16),

          // Row with two columns
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Job Title + Company
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(jobTitle, style: JobCardConstants.jobTitleStyle),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        companyName,
                        style: JobCardConstants.companyNameStyle,
                      ),
                      const SizedBox(width: 6),
                      const Text("✨", style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ],
              ),

              // Right: Experience + Location
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    buildTag(experienceLevel, Colors.tealAccent.shade100),
                    const SizedBox(height: 6),
                    buildTag(location, Colors.amber.shade100),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTag(String label, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(JobCardConstants.tagRadius),
        boxShadow: JobCardConstants.tagShadow,
        border: Border.all(color: Colors.black.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: JobCardConstants.tagFontSize,
          fontWeight: JobCardConstants.tagFontWeight,
        ),
      ),
    );
  }
}
