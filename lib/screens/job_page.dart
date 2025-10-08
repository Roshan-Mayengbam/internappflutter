import 'package:flutter/material.dart';
import 'package:internappflutter/home/cardDetails.dart';
import 'package:internappflutter/models/jobs.dart';
import 'package:provider/provider.dart';
import '../core/components/jobs_page/custom_carousel_section.dart';

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
    'Featured',
    'Upcoming',
    'Live',
    'Remote',
    'In-Person',
  ];

  String selectedHackathonFilter = 'Upcoming';

  List<Map<String, dynamic>> jobsToDisplayFormat(List<Job> jobs) {
    return jobs.asMap().entries.map((entry) {
      int index = entry.key;
      Job job = entry.value;
      return {
        'jobTitle': job.title,
        'companyName': job.recruiter.isNotEmpty ? job.recruiter : 'Company',
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
        'college': job.college,
        'applied': job.applied ?? false, // ✅ Add this line
        'tagLabel': job.jobType == 'on-campus' ? 'On Campus' : 'In House',
        'tagColor': job.jobType == 'on-campus'
            ? const Color(0xFF6C63FF)
            : const Color(0xFFFFB347),
      };
    }).toList();
  }

  final List<Map<String, dynamic>> hackathons = const [
    {
      'jobTitle': 'AI for Good Challenge',
      'companyName': 'Tech for Humanity',
      'location': 'Online',
      'experienceLevel': 'Undergraduates',
      'date': 'October 25-27, 2025',
      'theme': 'Using AI to solve social and environmental problems.',
      'prizes': ['\$5,000 Cash', 'Mentorship', 'Job Interviews'],
      'tags': ['AI', 'SOCIAL GOOD', 'VIRTUAL'],
      'applied': false,
    },
    {
      'jobTitle': 'Fintech Frontier Hack',
      'companyName': 'Finnovate Labs',
      'location': 'London',
      'date': 'November 1-3, 2025',
      'experienceLevel': 'Undergraduates',
      'theme': 'Innovations in financial technology and digital payments.',
      'prizes': ['\$10,000 Seed Funding', 'Incubator Spot'],
      'tags': ['FINTECH', 'IN-PERSON', 'LONDON'],
      'applied': false,
    },
    {
      'jobTitle': 'Health-Tech Innovation Sprint',
      'companyName': 'Global Health Institute',
      'location': 'Boston',
      'date': 'November 8-10, 2025',
      'experienceLevel': 'Working Professionals',
      'theme': 'Developing solutions for modern healthcare challenges.',
      'prizes': ['\$7,500 Grant', 'Partnership with Hospitals'],
      'tags': ['HEALTHCARE', 'MEDTECH', 'BOSTON'],
      'applied': false,
    },
    {
      'jobTitle': 'Game Jam 2025',
      'companyName': 'Indie Game Collective',
      'location': 'Online',
      'experienceLevel': 'High School',
      'date': 'December 6-8, 2025',
      'theme': 'Create a game from scratch in 48 hours.',
      'prizes': ['Publishing Deal', 'Console Dev Kits'],
      'tags': ['GAMING', 'DEVELOPMENT', 'VIRTUAL'],
      'applied': false,
    },
  ];
  @override
  void initState() {
    super.initState();
    // Fetch jobs when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().fetchJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<JobProvider>(
        builder: (context, jobProvider, child) {
          // Show loading indicator
          if (jobProvider.isLoading && jobProvider.jobs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error message
          if (jobProvider.errorMessage != null) {
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

          // Convert Job objects to Map format using the helper function
          final jobsList = jobsToDisplayFormat(jobProvider.jobs);

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),

                // Top Job Picks Section
                CustomCarouselSection(
                  title: 'Top job picks for you',
                  subtitle:
                      'Based on your profile, preference and activity like applies, searches and saves',
                  filters: jobFilters,
                  selectedFilter: selectedJobFilter,
                  onFilterTap: (filter) {
                    setState(() {
                      selectedJobFilter = filter;
                    });
                  },
                  onViewMore: () {
                    print("Pressed View more in jobs display");
                  },
                  statusPage: true,
                  items: jobsList,
                  onItemTap: (job) {
                    // Add this callback to handle navigation
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
                          rolesAndResponsibilities: job['description'] ?? '',
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
                        ),
                      ),
                    );
                  },
                  onCarouselTap: (String) {},
                ),
                const SizedBox(height: 30),
                CustomCarouselSection(
                  title: 'Hackathon',
                  subtitle: 'Based on your profile...',
                  filters: hackathonFilters,
                  selectedFilter: selectedHackathonFilter,
                  onFilterTap: (filter) {
                    setState(() {
                      selectedHackathonFilter = filter;
                    });
                  },
                  onViewMore: () {
                    print("Pressed View more in hackathons");
                  },
                  items: hackathons,
                  onCarouselTap: (String) {}, // Add hackathon data here
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

  // You can add hackathons section separately if you have that data
                // CustomCarouselSection(
                //   title: 'Hackathon',
                //   subtitle: 'Based on your profile...',
                //   filters: hackathonFilters,
                //   selectedFilter: selectedHackathonFilter,
                //   onFilterTap: (filter) {
                //     setState(() {
                //       selectedHackathonFilter = filter;
                //     });
                //   },
                //   onViewMore: () {
                //     print("Pressed View more in hackathons");
                //   },
                //   items: [], // Add hackathon data here
                // ),