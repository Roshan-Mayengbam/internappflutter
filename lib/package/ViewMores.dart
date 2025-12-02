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
  final bool hackathonPage; // <-- Added flag

  const ViewMores({
    super.key,
    required this.items,
    required this.statusPage,
    this.isAppliedSection = false,
    this.hackathonPage = false, // <-- Default value
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Take only 10 items if list is longer

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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              childAspectRatio: 1.4,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: items.length,
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
                                        item['description'] ?? '',
                                    duration:
                                        item['duration'] ?? 'Not specified',
                                    stipend:
                                        item['stipend']?.toString() ??
                                        'Not specified',
                                    details: item['description'] ?? '',
                                    noOfOpenings:
                                        item['noOfOpenings']?.toString() ?? '0',
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
                                  ),
                                ),
                              );
                            },
                            child: CarouselCard(
                              title: item["jobTitle"] ?? "Unknown Job",
                              subtitle:
                                  item["companyName"] ?? "Unknown Company",
                              location: item["location"],
                              tag1: isAppliedSection
                                  ? (item["applicationStatus"] ?? "Applied")
                                  : statusPage
                                  ? (item["applied"] == true
                                        ? "Applied"
                                        : "Not Applied")
                                  : (item["location"] ?? "Location N/A"),
                              tag2: isAppliedSection
                                  ? null
                                  : item['experienceLevel'] ?? "Entry level",
                              statusCard: isAppliedSection,
                            ),
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
