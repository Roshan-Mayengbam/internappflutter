import 'package:flutter/material.dart';
import 'package:internappflutter/core/constants/job_carousel_card_constants.dart';

class CarouselCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String tag1;
  final String tag2;
  final bool statusCard;
  final bool isVerified;

  const CarouselCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.tag1,
    this.tag2 = "",
    this.statusCard = true,
    this.isVerified = false,
  }) : assert(
         statusCard || tag2 != "",
         "If statusCard is false, tag2 must not be empty",
       );

  @override
  Widget build(BuildContext context) {
    return Container(
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
                title,
                style: JobCardConstants.bannerTextStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Row with two columns
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Title + Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: JobCardConstants.jobTitleStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            subtitle,
                            style: JobCardConstants.companyNameStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 3),
                            const Icon(Icons.verified, color: Colors.blue),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Right: Tags (1 or 2 depending on statusCard)
                SizedBox(
                  width: 100,
                  child: statusCard
                      ? buildTag(tag1)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            buildTag(tag1),
                            const SizedBox(height: 6),
                            buildTag(tag2),
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
