import 'package:flutter/material.dart';
import 'package:internappflutter/features/core/design_systems/app_colors.dart';
import 'package:internappflutter/home/cardDetails.dart';
import 'package:internappflutter/common/components/jobs_page/job_carousel_card.dart';
import 'package:internappflutter/common/components/custom_button.dart';
import 'package:internappflutter/features/core/design_systems/app_typography.dart';
import 'package:internappflutter/features/core/design_systems/app_spacing.dart';

class ViewMores extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final bool statusPage;
  final bool isAppliedSection;
  final bool hackathonPage;

  const ViewMores({
    super.key,
    required this.items,
    required this.statusPage,
    this.isAppliedSection = false,
    this.hackathonPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              child: Row(
                children: [
                  CustomButton(
                    buttonIcon: Icons.arrow_back,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Text(
                      hackathonPage
                          ? 'Hackathons'
                          : isAppliedSection
                          ? 'Applied Jobs'
                          : statusPage
                          ? 'Saved Jobs'
                          : 'All Jobs',
                      style: AppTypography.headingLg.copyWith(fontSize: 24),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          // Calculate dynamic aspect ratio based on screen size
                          // This ensures cards fit properly on all devices
                          final screenHeight = MediaQuery.of(
                            context,
                          ).size.height;
                          final availableHeight = constraints.maxHeight;

                          // Adjust aspect ratio for different screen sizes
                          double aspectRatio;
                          if (screenHeight < 700) {
                            // Small devices (e.g., iPhone SE)
                            aspectRatio = 1.5;
                          } else if (screenHeight < 800) {
                            // Medium devices
                            aspectRatio = 1.45;
                          } else {
                            // Large devices
                            aspectRatio = 1.4;
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.only(top: 8, bottom: 16),
                            itemCount: items.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final item = items[index];

                              return InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => Carddetails(
                                        jobTitle: item['jobTitle'] ?? '',
                                        companyName: item['companyName'] ?? '',
                                        location: item['location'] ?? '',
                                        experienceLevel:
                                            item['experienceLevel'] ?? '',
                                        requirements: List<String>.from(
                                          item['requirements'] ?? [],
                                        ),
                                        websiteUrl: item['websiteUrl'] ?? '',
                                        tagLabel: item['tagLabel'],
                                        employmentType: item['jobType'] ?? '',
                                        rolesAndResponsibilities:
                                            item['rolesAndResponsibilities'] ??
                                            '',
                                        duration:
                                            item['duration'] ?? 'Not specified',
                                        stipend:
                                            item['stipend']?.toString() ??
                                            'Not specified',
                                        details: item['description'] ?? '',
                                        noOfOpenings:
                                            item['noOfOpenings']?.toString() ??
                                            '0',
                                        mode: item['mode'] ?? 'N/A',
                                        skills: List<String>.from(
                                          item['requirements'] ?? [],
                                        ),
                                        id: item['jobId'] ?? '',
                                        jobType: item['jobType'] ?? '',
                                        recruiter: item['recruiter'],
                                        about:
                                            item['about'] ??
                                            'Description not available',
                                        salaryRange:
                                            item['salaryRange'] ??
                                            'Salary not available',
                                        perks: List<String>.from(
                                          item['perks'] ?? [],
                                        ),
                                        description: item['description'] ?? '',
                                        applicationStatus:
                                            item['applicationStatus'],
                                        matchScore: item['matchScore'],
                                      ),
                                    ),
                                  );
                                },
                                child: AspectRatio(
                                  aspectRatio: aspectRatio,
                                  child: CarouselCard(
                                    title: item["jobTitle"] ?? "Unknown Job",
                                    subtitle:
                                        item["companyName"] ??
                                        "Unknown Company",
                                    location: item["location"],
                                    tag1: isAppliedSection
                                        ? (item["applicationStatus"] ??
                                              "Applied")
                                        : statusPage
                                        ? (item["applied"] == true
                                              ? "Applied"
                                              : "Not Applied")
                                        : (item["location"] ?? "Location N/A"),
                                    tag2: isAppliedSection
                                        ? null
                                        : item['experienceLevel'] ??
                                              "Entry level",
                                    statusCard: isAppliedSection,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
