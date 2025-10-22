import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internappflutter/auth/page2.dart';
import 'package:internappflutter/chat/chatpage.dart';
import 'package:internappflutter/chat/chatscreen.dart';
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

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool _hasShownError = false;

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

  Map notifications = {
    'msg': [
      'New job matching your skills',
      'Application status updated',
      'On-campus opportunity available',
      'Profile viewed by recruiter',
      'Weekly job digest',
    ],
    'week': [
      '2 hours ago',
      '1 day ago',
      '2 days ago',
      '3 days ago',
      '1 week ago',
    ],
  };

  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _animations;

  int _topIndex = 0;

  // ✅ Use ValueNotifier for smoother updates without full rebuilds
  final ValueNotifier<double> _dragProgress = ValueNotifier(0.0);
  final ValueNotifier<DismissDirection?> _dragDirection = ValueNotifier(null);

  int _idx(int offset, int totalJobs) => (_topIndex + offset) % totalJobs;

  @override
  void initState() {
    super.initState();
    _initAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().fetchJobs();
    });
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      // Sign out from Google and Firebase
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();

      // Navigate to SignUpScreen and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Page2()),
        (route) => false, // remove all previous routes
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Sign out failed: $e")));
    }
  }

  void _initAnimations() {
    _controllers = List.generate(
      notifications['msg'].length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );
    _animations = List.generate(
      notifications['msg'].length,
      (index) => Tween<Offset>(begin: Offset.zero, end: Offset(1.5, 0)).animate(
        CurvedAnimation(parent: _controllers[index], curve: Curves.easeInOut),
      ),
    );
  }

  void _slideAllAndRemove() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      _controllers[i].forward();
    }
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      notifications['msg'].clear();
      notifications['week'].clear();
      _controllers.clear();
      _animations.clear();
    });
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
          Stack(
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
                  child: const Icon(
                    Icons.bookmark,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
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
                    top: BorderSide(
                      color: Color.fromARGB(255, 6, 7, 8),
                      width: 1,
                    ),
                    left: BorderSide(
                      color: Color.fromARGB(255, 6, 7, 8),
                      width: 1,
                    ),
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
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Builder(
              //   builder: (context) => InkWell(
              //     onTap: () => Scaffold.of(context).openEndDrawer(),
              //     child: Container(
              //       decoration: BoxDecoration(
              //         boxShadow: const [
              //           BoxShadow(
              //             color: Colors.black,
              //             offset: Offset(0, 6),
              //             blurRadius: 0,
              //             spreadRadius: -2,
              //           ),
              //           BoxShadow(
              //             color: Colors.black,
              //             offset: Offset(6, 0),
              //             blurRadius: 0,
              //             spreadRadius: -2,
              //           ),
              //           BoxShadow(
              //             color: Colors.black,
              //             offset: Offset(6, 6),
              //             blurRadius: 0,
              //             spreadRadius: -2,
              //           ),
              //         ],
              //         color: Colors.white,
              //         borderRadius: BorderRadius.circular(10),
              //         border: const Border(
              //           top: BorderSide(
              //             color: Color.fromARGB(255, 6, 7, 8),
              //             width: 1,
              //           ),
              //           left: BorderSide(
              //             color: Color.fromARGB(255, 6, 7, 8),
              //             width: 1,
              //           ),
              //           right: BorderSide(
              //             color: Color.fromARGB(255, 6, 7, 8),
              //             width: 2,
              //           ),
              //           bottom: BorderSide(
              //             color: Color.fromARGB(255, 6, 7, 8),
              //             width: 2,
              //           ),
              //         ),
              //       ),
              //       padding: const EdgeInsets.all(8),
              //       child: Stack(
              //         children: [
              //           const Icon(
              //             Icons.notifications_none,
              //             color: Colors.black,
              //           ),
              //           if (notifications['msg'].isNotEmpty)
              //             Positioned(
              //               right: 0,
              //               top: 0,
              //               child: Container(
              //                 padding: const EdgeInsets.all(2),
              //                 decoration: BoxDecoration(
              //                   color: Colors.red,
              //                   borderRadius: BorderRadius.circular(10),
              //                 ),
              //                 constraints: const BoxConstraints(
              //                   minWidth: 16,
              //                   minHeight: 16,
              //                 ),
              //                 child: Text(
              //                   '${notifications['msg'].length}',
              //                   style: const TextStyle(
              //                     color: Colors.white,
              //                     fontSize: 10,
              //                   ),
              //                   textAlign: TextAlign.center,
              //                 ),
              //               ),
              //             ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initAnimations();
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    _dragProgress.dispose();
    _dragDirection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cardWidth = screenSize.width * 0.92;
    final cardHeight = screenSize.height * 0.55;

    return Consumer<JobProvider>(
      builder: (context, jobProvider, child) {
        final displayJobs = jobsToDisplayFormat(jobProvider.jobs);

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

        // Empty state
        if (displayJobs.isEmpty && !jobProvider.isLoading) {
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
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              _signOut(context);
                            },
                            child: const Text('Retry'),
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

        // Loading state
        if (jobProvider.isLoading && displayJobs.isEmpty) {
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
                  const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Finding the best jobs for you...',
                            style: TextStyle(color: Colors.grey),
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

        // ✅ Main content - Use ValueListenableBuilder for smooth animations
        return Scaffold(
          backgroundColor: Colors.white,
          endDrawer: Drawer(
            child: Stack(
              children: [
                Column(
                  children: [
                    const DrawerHeader(
                      decoration: BoxDecoration(color: Colors.blue),
                      child: Row(
                        children: [
                          Icon(
                            Icons.notifications,
                            color: Colors.white,
                            size: 30,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Notifications',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: notifications['msg'].isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.notifications_off,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'No notifications',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: notifications['msg'].length,
                              itemBuilder: (context, index) {
                                return SlideTransition(
                                  position: _animations[index],
                                  child: Dismissible(
                                    key: Key(
                                      notifications['msg'][index] +
                                          index.toString(),
                                    ),
                                    direction: DismissDirection.startToEnd,
                                    onDismissed: (direction) {
                                      setState(() {
                                        notifications['msg'].removeAt(index);
                                        notifications['week'].removeAt(index);
                                      });
                                    },
                                    child: Card(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      child: ListTile(
                                        leading: const Icon(Icons.work),
                                        title: Text(
                                          notifications['msg'][index],
                                        ),
                                        subtitle: Text(
                                          notifications['week'][index],
                                        ),
                                        trailing: const Icon(
                                          Icons.arrow_forward_ios,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
                if (notifications['msg'].isNotEmpty)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton(
                      onPressed: _slideAllAndRemove,
                      child: const Icon(Icons.clear_all),
                    ),
                  ),
              ],
            ),
          ),
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

                // ✅ Card stack with ValueListenableBuilder
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: displayJobs.length >= 3
                          ? ValueListenableBuilder<double>(
                              valueListenable: _dragProgress,
                              builder: (context, progress, _) {
                                return ValueListenableBuilder<
                                  DismissDirection?
                                >(
                                  valueListenable: _dragDirection,
                                  builder: (context, direction, _) {
                                    // ✅ Calculate transforms once
                                    final nextScale = 0.95 + (0.03 * progress);
                                    final nextTranslateY = 24 - (8 * progress);
                                    final thirdScale =
                                        0.90 + (0.03 * progress * 0.5);
                                    final thirdTranslateY =
                                        48 - (8 * progress * 0.5);
                                    final topAngle =
                                        (direction ==
                                                DismissDirection.startToEnd
                                            ? 1
                                            : direction ==
                                                  DismissDirection.endToStart
                                            ? -1
                                            : 0) *
                                        (0.20 * progress);

                                    return Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        // 3rd card (back)
                                        Transform.scale(
                                          scale: thirdScale,
                                          alignment: Alignment.bottomRight,
                                          child: Transform.translate(
                                            offset: Offset(0, thirdTranslateY),
                                            child: Transform.rotate(
                                              angle: 0.20,
                                              alignment: Alignment.bottomRight,
                                              child: _buildJobCard(
                                                displayJobs,
                                                _idx(2, displayJobs.length),
                                              ),
                                            ),
                                          ),
                                        ),

                                        // 2nd card (middle)
                                        Transform.scale(
                                          scale: nextScale,
                                          alignment: Alignment.bottomRight,
                                          child: Transform.translate(
                                            offset: Offset(0, nextTranslateY),
                                            child: Transform.rotate(
                                              angle: 0.10,
                                              alignment: Alignment.bottomRight,
                                              child: _buildJobCard(
                                                displayJobs,
                                                _idx(1, displayJobs.length),
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Top card (interactive)
                                        Transform.rotate(
                                          angle: topAngle,
                                          child: Dismissible(
                                            key: ValueKey(
                                              'job_${_idx(0, displayJobs.length)}_$_topIndex',
                                            ),
                                            direction:
                                                DismissDirection.horizontal,
                                            dismissThresholds: const {
                                              DismissDirection.startToEnd: 0.35,
                                              DismissDirection.endToStart: 0.35,
                                            },
                                            onUpdate: (details) {
                                              // ✅ Update ValueNotifiers instead of setState
                                              _dragProgress.value = details
                                                  .progress
                                                  .clamp(0.0, 1.0);
                                              _dragDirection.value =
                                                  details.direction;
                                            },
                                            onDismissed: (dismissDirection) {
                                              bool isLiked =
                                                  dismissDirection ==
                                                  DismissDirection.startToEnd;
                                              int currentIndex = _idx(
                                                0,
                                                displayJobs.length,
                                              );
                                              String jobId =
                                                  displayJobs[currentIndex]['jobId'];
                                              String jobType =
                                                  displayJobs[currentIndex]['jobType'] ??
                                                  'company';

                                              if ((_topIndex + 1) %
                                                      displayJobs.length ==
                                                  0) {
                                                print(
                                                  "Reached last card! Fetching new jobs...",
                                                );
                                                context
                                                    .read<JobProvider>()
                                                    .fetchJobs();
                                              }

                                              _handleJobAction(
                                                jobId,
                                                jobType,
                                                isLiked,
                                              );

                                              // ✅ Reset and update index
                                              setState(() {
                                                _topIndex =
                                                    (_topIndex + 1) %
                                                    displayJobs.length;
                                              });
                                              _dragProgress.value = 0.0;
                                              _dragDirection.value = null;
                                            },
                                            child: _buildJobCard(
                                              displayJobs,
                                              _idx(0, displayJobs.length),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            )
                          : displayJobs.isNotEmpty
                          ? _buildJobCard(displayJobs, 0)
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ Helper method to reduce code duplication
  Widget _buildJobCard(List<Map<String, dynamic>> jobs, int index) {
    final job = jobs[index];
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
    );
  }
}
