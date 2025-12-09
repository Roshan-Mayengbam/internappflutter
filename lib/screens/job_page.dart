import 'package:flutter/material.dart';
import 'package:internappflutter/features/core/design_systems/app_colors.dart';
import 'package:internappflutter/home/cardDetails.dart';
import 'package:internappflutter/models/jobs.dart';
import 'package:internappflutter/package/ViewMores.dart';
import 'package:internappflutter/screens/hackathon_details.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../common/components/jobs_page/custom_carousel_section.dart';
import '../models/hackathon.dart';
import 'hackathon.dart';
import 'hackathon_details.dart';

class JobPage extends StatefulWidget {
  const JobPage({super.key});

  @override
  State<JobPage> createState() => _JobPageState();
}

class _JobPageState extends State<JobPage> {
  final List<String> jobFilters = [
    'Featured',
    'Live',
    'Upcoming',
    'Always Open',
    'Full-Time',
    'Part-Time',
    'Internship',
  ];

  String selectedJobFilter = 'Featured';

  final List<String> hackathonFilters = [
    'All',
    'Upcoming',
    'Live',
    'Online',
    'Offline',
    'Hybrid',
  ];

  String selectedHackathonFilter = 'All';

  // Add state variables for view more functionality
  bool showAllJobs = false;
  bool showAllHackathons = false;
  final int initialJobsCount = 10;
  final int initialHackathonsCount = 10;

  List<Map<String, dynamic>> jobsToDisplayFormat(List<Job> jobs) {
    return jobs.asMap().entries.map((entry) {
      int index = entry.key;
      Job job = entry.value;

      // Create recruiter map - handle both populated and unpopulated cases
      Map<String, dynamic>? recruiterMap;
      if (job.recruiterDetails != null) {
        // Recruiter is populated
        recruiterMap = job.recruiterDetails;
      } else if (job.recruiter is String && job.recruiter.isNotEmpty) {
        // Recruiter is just an ID - create minimal map
        recruiterMap = {
          'id': job.recruiter,
          'name': 'Unknown',
          'email': 'N/A',
          'firebaseId': job.recruiter,
          'designation': 'N/A',
          'company': {'name': 'Unknown Company'},
        };
      }

      return {
        'jobTitle': job.title,
        'id': job.id,
        'jobType': job.jobType,
        'companyName':
            job.recruiterDetails?['company']?['name']?.isNotEmpty == true
            ? job.recruiterDetails?['company']?['name']
            : job.recruiterName.isNotEmpty
            ? job.recruiterName
            : 'Company',
        'about':
            job.recruiterDetails?['company']?['description']?.isNotEmpty == true
            ? job.recruiterDetails?['company']?['description']
            : job.recruiterName.isNotEmpty
            ? job.recruiterName
            : 'description not available',
        'location': job.preferences.location.isNotEmpty
            ? job.preferences.location
            : 'Location not specified',
        'experienceLevel': job.preferences.minExperience > 0
            ? '${job.preferences.minExperience}+ years'
            : 'Entry level',
        'requirements': job.preferences.skills.isNotEmpty
            ? job.preferences.skills
            : ['Skills not specified'],
        'websiteUrl': job.applicationLink ?? 'Apply via app',
        'initialColorIndex': index % 3,
        'description': job.description,
        'salaryRange':
            '₹${job.salaryRange.min.toInt()}k - ₹${job.salaryRange.max.toInt()}k',
        'jobId': job.id,
        'jobType': job.jobType,
        'college': job.college ?? 'N/A',
        'tagLabel': job.jobType == 'on-campus'
            ? 'On Campus'
            : job.jobType == 'external'
            ? 'External'
            : 'In House',
        'tagColor': job.jobType == 'on-campus'
            ? const Color(0xFF6C63FF)
            : job.jobType == 'external'
            ? const Color(0xFF00BFA6)
            : const Color(0xFFFFB347),
        'employmentType': job.employmentType,
        'rolesAndResponsibilities':
            job.rolesAndResponsibilities?.isNotEmpty == true
            ? job.rolesAndResponsibilities
            : 'Not specified',
        'perks': job.perks?.isNotEmpty == true ? job.perks : 'Not specified',
        'details': job.details?.isNotEmpty == true
            ? job.details
            : 'Not specified',
        'noOfOpenings': job.noOfOpenings.toString(),
        'duration': job.duration?.isNotEmpty == true
            ? job.duration
            : 'Not specified',
        'skills': job.preferences.skills,
        'mode': job.mode.isNotEmpty ? job.mode : 'Not specified',
        'stipend': job.stipend != null ? '₹${job.stipend}' : 'Not specified',

        // Use the recruiterMap we created
        'recruiter': recruiterMap,
      };
    }).toList();
  }

  List<Map<String, dynamic>> hackathonsToDisplayFormat(
    List<Hackathon> hackathons,
  ) {
    final now = DateTime.now();

    return hackathons.map((hackathon) {
      // Determine status
      String status;
      if (now.isBefore(hackathon.startDate)) {
        status = 'Upcoming';
      } else if (now.isAfter(hackathon.endDate)) {
        status = 'Ended';
      } else {
        status = 'Live';
      }

      // Format dates
      final dateFormat = DateFormat('MMM dd, yyyy');
      final dateRange =
          '${dateFormat.format(hackathon.startDate)} - ${dateFormat.format(hackathon.endDate)}';

      return {
        'id': hackathon.id,
        'jobTitle': hackathon.title,
        'companyName': hackathon.organizer,
        'location': hackathon.location,
        'experienceLevel': hackathon.eligibility,
        'date': dateRange,
        'theme': hackathon.description,
        'prizes': hackathon.prizePool != null
            ? [hackathon.prizePool!]
            : ['Prize details not available'],
        'tags': [hackathon.location.toUpperCase(), status.toUpperCase()],
        'websiteUrl': hackathon.website ?? 'Apply via app',
        'applied': false,
        'status': status,
        'registrationDeadline': hackathon.registrationDeadline,
      };
    }).toList();
  }

  List<Map<String, dynamic>> filterHackathons(
    List<Map<String, dynamic>> hackathons,
  ) {
    if (selectedHackathonFilter == 'All') {
      return hackathons;
    }

    return hackathons.where((hackathon) {
      switch (selectedHackathonFilter) {
        case 'Upcoming':
          return hackathon['status'] == 'Upcoming';
        case 'Live':
          return hackathon['status'] == 'Live';
        case 'Online':
          return hackathon['location'] == 'Online';
        case 'Offline':
          return hackathon['location'] == 'Offline';
        case 'Hybrid':
          return hackathon['location'] == 'Hybrid';
        default:
          return true;
      }
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    // Fetch jobs and hackathons when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().fetchJobs();
      context.read<HackathonProvider>().fetchHackathons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Consumer2<JobProvider, HackathonProvider>(
        builder: (context, jobProvider, hackathonProvider, child) {
          // Show loading indicator
          if ((jobProvider.isLoading && jobProvider.jobs.isEmpty) ||
              (hackathonProvider.isLoading &&
                  hackathonProvider.hackathons.isEmpty)) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/animations/searching/searching_lottie.json',
                    width: 300,
                    height: 300,
                    repeat: true, // Keep the animation looping
                    animate: true, // Ensure the animation starts
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Fetching the latest data...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            );
          }

          // Show error message for jobs
          if (jobProvider.errorMessage != null && jobProvider.jobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    jobProvider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => jobProvider.fetchJobs(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Convert Job objects to Map format
          final allJobs = jobsToDisplayFormat(jobProvider.jobs);

          // Limit jobs based on showAllJobs state
          final jobsList = showAllJobs
              ? allJobs
              : allJobs.take(initialJobsCount).toList();

          // Convert Hackathon objects to Map format
          final allFilteredHackathons = filterHackathons(
            hackathonsToDisplayFormat(hackathonProvider.hackathons),
          );

          // Limit hackathons based on showAllHackathons state
          final filteredHackathons = showAllHackathons
              ? allFilteredHackathons
              : allFilteredHackathons.take(initialHackathonsCount).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Job Picks Section
                CustomCarouselSection(
                  title: 'Top job picks for you',
                  subtitle:
                      'Based on your profile, preference and activity like applies, searches and saves',
                  filters: jobFilters,
                  selectedFilter: selectedJobFilter,
                  isAppliedSection: false,
                  onFilterTap: (filter) {
                    setState(() {
                      selectedJobFilter = filter;
                    });
                  },
                  onViewMore: () {
                    // Navigate to ViewMores page with ALL jobs
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewMores(
                          items: allJobs, // Pass ALL jobs, not limited
                          isAppliedSection: false,
                          statusPage: false,
                        ),
                      ),
                    );
                  },
                  statusPage: false,
                  items: jobsList,
                  onItemTap: (job) {
                    print("---- Navigating to Carddetails ----");
                    print("Job Title: ${job['jobTitle']}");
                    print("Company Name: ${job['companyName']}");
                    print("Location: ${job['location']}");
                    print("Website URL: ${job['websiteUrl']}");
                    print("Job Type: ${job['jobType']}");
                    print("-----------------------------------");

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Carddetails(
                          jobTitle: job['jobTitle'] ?? '',
                          companyName: job['companyName'] ?? '',
                          location: job['location'] ?? '',
                          experienceLevel: job['experienceLevel'] ?? '',
                          requirements: job['requirements'] ?? [],
                          websiteUrl: job['websiteUrl'] ?? '',
                          tagLabel: job['tagLabel'],
                          employmentType: job['jobType'] ?? '',
                          rolesAndResponsibilities:
                              job['rolesAndResponsibilities'] ?? '',
                          duration:
                              jobProvider.jobs
                                  .firstWhere((j) => j.id == job['jobId'])
                                  .duration ??
                              'Not specified',
                          stipend:
                              jobProvider.jobs
                                  .firstWhere((j) => j.id == job['jobId'])
                                  .stipend
                                  ?.toString() ??
                              'Not specified',
                          details: job['description'] ?? '',
                          noOfOpenings: jobProvider.jobs
                              .firstWhere((j) => j.id == job['jobId'])
                              .noOfOpenings
                              .toString(),
                          mode: jobProvider.jobs
                              .firstWhere((j) => j.id == job['jobId'])
                              .mode,
                          skills: job['requirements'] ?? [],
                          id: job['jobId'] ?? '',
                          jobType: job['jobType'] ?? '',
                          recruiter: job['recruiter'],
                          about: job['about'] ?? 'description not available',
                          salaryRange:
                              job['salaryRange'] ?? 'salary not available',
                          perks: job['perks'] ?? 'perks not available',
                          description: job['description'] ?? '',
                        ),
                      ),
                    );
                  },
                  onCarouselTap: (String) {},
                ),
                const SizedBox(height: 30),

                // Hackathon Section
                CustomCarouselSection(
                  title: 'Hackathons',
                  subtitle: 'Compete, innovate, and win amazing prizes',
                  filters: hackathonFilters,
                  selectedFilter: selectedHackathonFilter,
                  isAppliedSection: false,
                  isHackathonPage: true,
                  onFilterTap: (filter) {
                    setState(() {
                      selectedHackathonFilter = filter;
                      // Reset showAllHackathons when filter changes
                      showAllHackathons = false;
                    });
                  },
                  onViewMore: () {
                    // Navigate to ViewMores page with ALL filtered hackathons
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewMores(
                          items:
                              allFilteredHackathons, // Pass ALL filtered hackathons
                          isAppliedSection: false,
                          statusPage: false,
                          hackathonPage: true,
                        ),
                      ),
                    );
                  },
                  items: filteredHackathons,
                  onItemTap: (hackathon) {
                    print("---- Navigating to HackathonDetailsScreen ----");
                    print("Hackathon Title: ${hackathon['jobTitle']}");
                    print("Organizer: ${hackathon['companyName']}");
                    print("Website URL: ${hackathon['websiteUrl']}");
                    print("---------------------------------------------");

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => HackathonDetailsScreen(
                          title: hackathon['jobTitle'] ?? '',
                          organizer: hackathon['companyName'] ?? '',
                          description: hackathon['theme'] ?? '',
                          location: hackathon['location'] ?? '',
                          startDate: hackathonProvider.hackathons
                              .firstWhere((h) => h.id == hackathon['id'])
                              .startDate,
                          endDate: hackathonProvider.hackathons
                              .firstWhere((h) => h.id == hackathon['id'])
                              .endDate,
                          registrationDeadline: hackathonProvider.hackathons
                              .firstWhere((h) => h.id == hackathon['id'])
                              .registrationDeadline,
                          prizePool: hackathon['prizes']?.isNotEmpty == true
                              ? hackathon['prizes']![0]
                              : null,
                          eligibility:
                              hackathon['experienceLevel'] ?? 'Open to all',
                          website: hackathon['websiteUrl'] ?? 'N/A',
                          createdAt: hackathonProvider.hackathons
                              .firstWhere((h) => h.id == hackathon['id'])
                              .createdAt,
                          updatedAt: hackathonProvider.hackathons
                              .firstWhere((h) => h.id == hackathon['id'])
                              .updatedAt,
                        ),
                      ),
                    );
                  },

                  onCarouselTap: (hackathonId) {
                    print("Tapped hackathon: $hackathonId");
                    // Navigate to hackathon details page if you have one
                  },
                ),

                // Show error for hackathons if any
                if (hackathonProvider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Hackathons: ${hackathonProvider.errorMessage}',
                      style: const TextStyle(color: Colors.orange),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
