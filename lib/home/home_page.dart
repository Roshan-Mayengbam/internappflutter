import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internappflutter/auth/page2.dart';
import 'package:internappflutter/chat/chatpage.dart';
import 'package:internappflutter/home/saved.dart';
import 'package:provider/provider.dart';
import 'package:internappflutter/models/jobs.dart';
import 'job_card.dart';

class HomePage extends StatefulWidget {
  final dynamic userData;
  const HomePage({super.key, required this.userData});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool _hasShownError = false;
  late AppinioSwiperController _swiperController;

  @override
  void initState() {
    super.initState();
    _swiperController = AppinioSwiperController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().fetchJobs();
    });
  }

  // Convert API Job to display format
  List<Map<String, dynamic>> jobsToDisplayFormat(List<Job> jobs) {
    return jobs.asMap().entries.map((entry) {
      int index = entry.key;
      Job job = entry.value;

      Map<String, dynamic>? recruiterMap;
      if (job.recruiterDetails != null) {
        recruiterMap = job.recruiterDetails;
      } else if (job.recruiter is String && job.recruiter.isNotEmpty) {
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
        'recruiter': recruiterMap,
      };
    }).toList();
  }

  void _handleJobAction(String jobId, String jobType, bool isLiked) async {
    if (isLiked) {
      print("Attempting to apply for job: $jobId (Type: $jobType)");
      context.read<JobProvider>().clearError();
      _hasShownError = false;
      await context.read<JobProvider>().applyJob(jobId, jobType);
    }
  }

  void _retryFetchJobs() {
    final jobProvider = context.read<JobProvider>();
    jobProvider.clearError();
    _hasShownError = false;
    jobProvider.fetchJobs();
  }

  Widget _buildTopBar(JobProvider jobProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Saved()),
              );
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(0, 6),
                    blurRadius: 0,
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(6, 0),
                    blurRadius: 0,
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(6, 6),
                    blurRadius: 0,
                    spreadRadius: -2,
                  ),
                ],
                color: const Color(0xFFD9FFCB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black, width: 1),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.bookmark, color: Colors.black, size: 28),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(0, 6),
                  blurRadius: 0,
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(6, 0),
                  blurRadius: 0,
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(6, 6),
                  blurRadius: 0,
                  spreadRadius: -2,
                ),
              ],
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: const Border(
                top: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 1),
                left: BorderSide(color: Color.fromARGB(255, 6, 7, 8), width: 1),
                right: BorderSide(
                  color: Color.fromARGB(255, 6, 7, 8),
                  width: 2,
                ),
                bottom: BorderSide(
                  color: Color.fromARGB(255, 6, 7, 8),
                  width: 2,
                ),
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatPage()),
                );
              },
              child: const Icon(Icons.chat_bubble_outline, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cardWidth = screenSize.width * 0.92;
    final cardHeight = screenSize.height * 0.55;

    return Consumer<JobProvider>(
      builder: (context, jobProvider, child) {
        // Error handling
        if (jobProvider.errorMessage != null && !_hasShownError) {
          _hasShownError = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(jobProvider.errorMessage!),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                  action: SnackBarAction(
                    label: 'Retry',
                    textColor: Colors.white,
                    onPressed: _retryFetchJobs,
                  ),
                ),
              );
            }
          });
        }

        if (jobProvider.errorMessage == null && _hasShownError) {
          _hasShownError = false;
        }

        // Loading state
        if (jobProvider.isLoading && jobProvider.jobs.isEmpty) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  _buildTopBar(jobProvider),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "SWIPE AND PICK YOUR JOB",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 1500),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: 0.8 + (value * 0.2),
                                child: Icon(
                                  Icons.search,
                                  size: 80,
                                  color: Colors.black.withValues(
                                    alpha: 0.3 + (value * 0.4),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Finding jobs for you...',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              fontFamily: 'jost',
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Hang tight! We\'re searching for the best opportunities',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontFamily: 'jost',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          const SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Empty state
        if (jobProvider.jobs.isEmpty && !jobProvider.isLoading) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: RefreshIndicator(
              onRefresh: () async {
                await context.read<JobProvider>().fetchJobs();
              },
              color: Colors.black,
              backgroundColor: const Color(0xFFD9FFCB),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top,
                  child: Column(
                    children: [
                      _buildTopBar(jobProvider),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "SWIPE AND PICK YOUR JOB",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.work_off,
                                size: 80,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                jobProvider.errorMessage ?? 'No jobs available',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Pull down to refresh',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _retryFetchJobs,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // Main content with Appinio Swiper
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                _buildTopBar(jobProvider),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "SWIPE AND PICK YOUR JOB",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 8,
                      bottom: 100,
                    ),
                    child: SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: Selector<JobProvider, List<Job>>(
                        selector: (context, provider) => provider.jobs,
                        builder: (context, jobs, child) {
                          final displayJobs = jobsToDisplayFormat(jobs);
                          return AppinioSwiper(
                            controller: _swiperController,
                            cardCount: displayJobs.length,
                            onSwipeEnd:
                                (
                                  int previousIndex,
                                  int targetIndex,
                                  SwiperActivity activity,
                                ) {
                                  // Check if we're near the end
                                  if (previousIndex >= displayJobs.length - 2) {
                                    print(
                                      "Near end of cards! Fetching new jobs...",
                                    );
                                    context.read<JobProvider>().fetchJobs();
                                  }

                                  // Handle job action
                                  bool isLiked =
                                      activity.direction == AxisDirection.right;
                                  String jobId =
                                      displayJobs[previousIndex]['jobId'];
                                  String jobType =
                                      displayJobs[previousIndex]['jobType'] ??
                                      'company';

                                  _handleJobAction(jobId, jobType, isLiked);
                                },
                            onEnd: () {
                              print("All cards swiped!");
                              context.read<JobProvider>().fetchJobs();
                            },
                            cardBuilder: (BuildContext context, int index) {
                              return _buildJobCard(displayJobs, index);
                            },
                            // Customization options
                            swipeOptions: const SwipeOptions.only(
                              left: true,
                              right: true,
                            ),
                            duration: const Duration(milliseconds: 200),
                            maxAngle: 30,
                            threshold: 80,
                            isDisabled: false,
                            backgroundCardCount: 2,
                            backgroundCardScale: 0.92,
                            backgroundCardOffset: const Offset(0, 27),
                            loop: true,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildJobCard(List<Map<String, dynamic>> jobs, int index) {
    final job = jobs[index];

    List<String> perksList = [];
    if (job['perks'] != null) {
      if (job['perks'] is List) {
        perksList = List<String>.from(job['perks']);
      } else if (job['perks'] is String) {
        String perksString = job['perks'];
        perksList = perksString
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .map((line) => line.replaceFirst(RegExp(r'^[•\-\*]\s*'), ''))
            .where((line) => line.isNotEmpty)
            .toList();
      }
    }

    return JobCard(
      jobTitle: job['jobTitle'],
      companyName: job['companyName'],
      location: job['location'],
      experienceLevel: job['experienceLevel'],
      requirements: List<String>.from(job['requirements']),
      websiteUrl: job['websiteUrl'],
      initialColorIndex: job['initialColorIndex'],
      tagLabel: job['tagLabel'],
      tagColor: job['tagColor'],
      skills: List<String>.from(job['skills'] ?? []),
      employmentType: job['employmentType'] ?? '',
      rolesAndResponsibilities: job['rolesAndResponsibilities'] ?? '',
      duration: job['duration'] ?? '',
      stipend: job['stipend'] ?? '',
      details: job['details'] ?? '',
      noOfOpenings: job['noOfOpenings'] ?? '',
      mode: job['mode'] ?? '',
      id: job['id'] ?? '',
      jobType: job['jobType'] ?? '',
      recruiter: job['recruiter'] as Map<String, dynamic>?,
      about: job['about'] ?? 'description not available',
      salaryRange: job['salaryRange'] ?? 'salary not available',
      perks: perksList,
      description: job['description'] ?? 'description not available',
    );
  }
}
