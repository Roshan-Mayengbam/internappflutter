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
      // Added a fixed width to the card for consistent sizing in the list view
      width: 320,
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
              child: Text(
                jobTitle,
                style: JobCardConstants.bannerTextStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Row with two columns
          SizedBox(
            // Wrapped the row in a sized box to constrain its width
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Job Title + Company
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jobTitle,
                        style: JobCardConstants.jobTitleStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            companyName,
                            style: JobCardConstants.companyNameStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 3),
                          const Icon(Icons.verified, color: Colors.blue),
                        ],
                      ),
                    ],
                  ),
                ),

                // Right: Experience + Location
                SizedBox(
                  width: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      buildTag(experienceLevel),
                      const SizedBox(height: 6),
                      buildTag(location),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTag(String label) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
