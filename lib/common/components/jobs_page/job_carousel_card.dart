import 'package:flutter/material.dart';
import 'package:internappflutter/common/constants/job_carousel_card_constants.dart';

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
          mainAxisSize: MainAxisSize.min, // ✅ Prevent overflow
          children: [
            // Banner
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 120, // ✅ Reduced from 140 to prevent overflow
                decoration: const BoxDecoration(
                  gradient: JobCardConstants.bannerGradient,
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    title,
                    style: JobCardConstants.bannerTextStyle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2, // ✅ Allow 2 lines for long titles
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12), // ✅ Reduced from 16
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
                          style: JobCardConstants.jobTitleStyle,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4), // ✅ Reduced from 6
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                subtitle,
                                style: JobCardConstants.companyNameStyle,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            if (isVerified) ...[
                              const SizedBox(width: 3),
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

                  const SizedBox(width: 8), // ✅ Add spacing between columns
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
                                const SizedBox(height: 4), // ✅ Reduced from 6
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
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }
}
