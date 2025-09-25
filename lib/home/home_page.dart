import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart'; // Added missing import

import 'package:internappflutter/models/jobs.dart';
import 'job_card.dart';

class HomePage extends StatefulWidget {
  final dynamic userData; // Fixed parameter declaration
  const HomePage({super.key, required this.userData});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // Convert API Job to display format
  List<Map<String, dynamic>> jobsToDisplayFormat(List<Job> jobs) {
    return jobs.asMap().entries.map((entry) {
      int index = entry.key;
      Job job = entry.value;
      return {
        'jobTitle': job.title,
        'companyName':
            'Company', // You might want to extract this from recruiter field
        'location': job.preferences.location,
        'experienceLevel': '${job.preferences.minExperience}+ years',
        'requirements': job.preferences.skills.isNotEmpty
            ? job.preferences.skills
            : ['Skills not specified'],
        'websiteUrl': 'www.company.com',
        'initialColorIndex': index % 3,
        'description': job.description,
        'salaryRange':
            '₹${job.salaryRange.min.toInt()}k - ₹${job.salaryRange.max.toInt()}k',
        'jobId': job.id, // Add jobId for applying
      };
    }).toList();
  }

  // Notification data
  Map notifications = {
    'msg': [
      'UI/UX Designer',
      'UI/UX Designer',
      'UI/UX Designer',
      'UI/UX Designer',
      'UI/UX Designer',
    ],
    'week': [
      '1 week ago',
      '1 week ago',
      '1 week ago',
      '1 week ago',
      '1 week ago',
    ],
  };

  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _animations;

  // Which card is currently on top
  int _topIndex = 0;

  // Live drag progress to animate the stack (0.0 -> 1.0)
  double _dragProgress = 0.0;
  DismissDirection? _dragDirection;

  int _idx(int offset, int totalJobs) => (_topIndex + offset) % totalJobs;

  @override
  void initState() {
    super.initState();
    _initAnimations();

    // Load jobs when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().fetchJobs();
    });
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

  void _slideAndRemove(int index) async {
    await _controllers[index].forward();
    setState(() {
      notifications['msg'].removeAt(index);
      notifications['week'].removeAt(index);
      _controllers.removeAt(index);
      _animations.removeAt(index);
    });
  }

  void _slideAllAndRemove() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(Duration(milliseconds: 100));
      _controllers[i].forward();
    }
    await Future.delayed(Duration(milliseconds: 400));
    setState(() {
      notifications['msg'].clear();
      notifications['week'].clear();
      _controllers.clear();
      _animations.clear();
    });
  }

  void _handleJobAction(String jobId, bool isLiked) async {
    if (isLiked) {
      print("🚀 Attempting to apply for job: $jobId");

      // ✅ NO NEED TO PASS STUDENT ID - IT COMES FROM TOKEN
      await context.read<JobProvider>().applyJob(jobId);

      final jobProvider = context.read<JobProvider>();
      if (jobProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jobProvider.errorMessage!),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Applied to job successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      print("❌ Job rejected: $jobId");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Job rejected'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  // Fixed: Extract top bar building into a method
  Widget _buildTopBar(JobProvider jobProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(
            children: [
              Positioned(
                left: 8,
                top: 8,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  boxShadow: [
                    // Bottom shadow
                    const BoxShadow(
                      color: Colors.black,
                      offset: Offset(0, 6),
                      blurRadius: 0,
                      spreadRadius: -2,
                    ),
                    // Right shadow
                    const BoxShadow(
                      color: Colors.black,
                      offset: Offset(6, 0),
                      blurRadius: 0,
                      spreadRadius: -2,
                    ),
                    // Bottom-right corner shadow (to make it symmetric)
                    const BoxShadow(
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
                child: const Icon(Icons.tune, color: Colors.black),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    // Bottom shadow
                    const BoxShadow(
                      color: Colors.black,
                      offset: Offset(0, 6),
                      blurRadius: 0,
                      spreadRadius: -2,
                    ),
                    // Right shadow
                    const BoxShadow(
                      color: Colors.black,
                      offset: Offset(6, 0),
                      blurRadius: 0,
                      spreadRadius: -2,
                    ),
                    // Bottom-right corner shadow (to make it symmetric)
                    const BoxShadow(
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
                    ), // thin
                    left: BorderSide(
                      color: Color.fromARGB(255, 6, 7, 8),
                      width: 1,
                    ), // thin
                    right: BorderSide(
                      color: Color.fromARGB(255, 6, 7, 8),
                      width: 2,
                    ), // thick
                    bottom: BorderSide(
                      color: Color.fromARGB(255, 6, 7, 8),
                      width: 2,
                    ), // thick
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 12),
              Builder(
                builder: (context) => InkWell(
                  onTap: () => Scaffold.of(context).openEndDrawer(),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        // Bottom shadow
                        const BoxShadow(
                          color: Colors.black,
                          offset: Offset(0, 6),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                        // Right shadow
                        const BoxShadow(
                          color: Colors.black,
                          offset: Offset(6, 0),
                          blurRadius: 0,
                          spreadRadius: -2,
                        ),
                        // Bottom-right corner shadow (to make it symmetric)
                        const BoxShadow(
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
                        ), // thin
                        left: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 1,
                        ), // thin
                        right: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 2,
                        ), // thick
                        bottom: BorderSide(
                          color: Color.fromARGB(255, 6, 7, 8),
                          width: 2,
                        ), // thick
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.notifications_none,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cardWidth = screenSize.width - 40.0;
    final cardHeight = screenSize.height * 0.50;

    return Consumer<JobProvider>(
      builder: (context, jobProvider, child) {
        final displayJobs = jobsToDisplayFormat(jobProvider.jobs);

        // Show error message if there's an error
        if (jobProvider.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(jobProvider.errorMessage!),
                action: SnackBarAction(
                  label: 'Retry',
                  onPressed: () => jobProvider.fetchJobs(),
                ),
              ),
            );
          });
        }

        if (displayJobs.isEmpty && !jobProvider.isLoading) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  // Top bar
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

                  // Empty state
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
                          const Text(
                            'No jobs available',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => jobProvider.fetchJobs(),
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
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
            ),
          );
        }

        // Back-card animation based on drag progress
        final nextScale = 0.95 + (0.03 * _dragProgress);
        final nextTranslateY = 24 - (8 * _dragProgress);

        final thirdScale = 0.90 + (0.03 * _dragProgress * 0.5);
        final thirdTranslateY = 48 - (8 * _dragProgress * 0.5);

        // Top-card rotation based on drag direction
        final topAngle =
            (_dragDirection == DismissDirection.startToEnd
                ? 1
                : _dragDirection == DismissDirection.endToStart
                ? -1
                : 0) *
            (0.20 * _dragProgress);

        return Scaffold(
          backgroundColor: Colors.white,
          endDrawer: Drawer(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 72.0),
                  child: ListView.builder(
                    itemCount: notifications['msg'].length,
                    itemBuilder: (context, index) {
                      return SlideTransition(
                        position: _animations[index],
                        child: Dismissible(
                          key: Key(
                            notifications['msg'][index] + index.toString(),
                          ),
                          direction: DismissDirection.startToEnd,
                          onDismissed: (direction) {
                            //_slideAndRemove(index);
                          },
                          movementDuration: const Duration(milliseconds: 400),
                          child: Card(
                            child: ListTile(
                              title: Text(notifications['msg'][index]),
                              subtitle: Text(notifications['week'][index]),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: _slideAllAndRemove,
                    child: Icon(Icons.clear_all),
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Top bar
                _buildTopBar(jobProvider), // Fixed: Use the extracted method

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
                const SizedBox(height: 10),

                // Card stack
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // 3rd card (bottom)
                          Transform.scale(
                            scale: thirdScale,
                            alignment: Alignment.bottomRight,
                            child: Transform.translate(
                              offset: Offset(0, thirdTranslateY),
                              child: Transform.rotate(
                                angle: 0.20, // slight playful tilt
                                alignment: Alignment.bottomRight,
                                child: JobCard(
                                  jobTitle:
                                      displayJobs[_idx(
                                        2,
                                        displayJobs.length,
                                      )]['jobTitle'],
                                  companyName:
                                      displayJobs[_idx(
                                        2,
                                        displayJobs.length,
                                      )]['companyName'],
                                  location:
                                      displayJobs[_idx(
                                        2,
                                        displayJobs.length,
                                      )]['location'],
                                  experienceLevel:
                                      displayJobs[_idx(
                                        2,
                                        displayJobs.length,
                                      )]['experienceLevel'],
                                  requirements: List<String>.from(
                                    displayJobs[_idx(
                                      2,
                                      displayJobs.length,
                                    )]['requirements'],
                                  ),
                                  websiteUrl:
                                      displayJobs[_idx(
                                        2,
                                        displayJobs.length,
                                      )]['websiteUrl'],
                                  initialColorIndex:
                                      displayJobs[_idx(
                                        2,
                                        displayJobs.length,
                                      )]['initialColorIndex'],
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
                                child: JobCard(
                                  jobTitle:
                                      displayJobs[_idx(
                                        1,
                                        displayJobs.length,
                                      )]['jobTitle'],
                                  companyName:
                                      displayJobs[_idx(
                                        1,
                                        displayJobs.length,
                                      )]['companyName'],
                                  location:
                                      displayJobs[_idx(
                                        1,
                                        displayJobs.length,
                                      )]['location'],
                                  experienceLevel:
                                      displayJobs[_idx(
                                        1,
                                        displayJobs.length,
                                      )]['experienceLevel'],
                                  requirements: List<String>.from(
                                    displayJobs[_idx(
                                      1,
                                      displayJobs.length,
                                    )]['requirements'],
                                  ),
                                  websiteUrl:
                                      displayJobs[_idx(
                                        1,
                                        displayJobs.length,
                                      )]['websiteUrl'],
                                  initialColorIndex:
                                      displayJobs[_idx(
                                        1,
                                        displayJobs.length,
                                      )]['initialColorIndex'],
                                ),
                              ),
                            ),
                          ),

                          // Top card (swipe with Dismissible)
                          Transform.rotate(
                            angle: topAngle,
                            child: Dismissible(
                              key: ValueKey(
                                'job_${_idx(0, displayJobs.length)}_$_topIndex',
                              ),
                              direction: DismissDirection.horizontal,
                              dismissThresholds: const {
                                DismissDirection.startToEnd: 0.35,
                                DismissDirection.endToStart: 0.35,
                              },
                              onUpdate: (details) {
                                setState(() {
                                  _dragProgress = details.progress.clamp(
                                    0.0,
                                    1.0,
                                  );
                                  _dragDirection = details.direction;
                                });
                              },
                              onDismissed: (direction) {
                                // Handle job action based on swipe direction
                                bool isLiked =
                                    direction == DismissDirection.startToEnd;
                                String jobId =
                                    displayJobs[_idx(
                                      0,
                                      displayJobs.length,
                                    )]['jobId'];
                                _handleJobAction(jobId, isLiked);

                                setState(() {
                                  _dragProgress = 0.0;
                                  _dragDirection = null;
                                  _topIndex =
                                      (_topIndex + 1) % displayJobs.length;
                                });
                              },
                              confirmDismiss: (direction) async {
                                // allow both left/right swipes
                                return true;
                              },
                              child: JobCard(
                                jobTitle:
                                    displayJobs[_idx(
                                      0,
                                      displayJobs.length,
                                    )]['jobTitle'],
                                companyName:
                                    displayJobs[_idx(
                                      0,
                                      displayJobs.length,
                                    )]['companyName'],
                                location:
                                    displayJobs[_idx(
                                      0,
                                      displayJobs.length,
                                    )]['location'],
                                experienceLevel:
                                    displayJobs[_idx(
                                      0,
                                      displayJobs.length,
                                    )]['experienceLevel'],
                                requirements: List<String>.from(
                                  displayJobs[_idx(
                                    0,
                                    displayJobs.length,
                                  )]['requirements'],
                                ),
                                websiteUrl:
                                    displayJobs[_idx(
                                      0,
                                      displayJobs.length,
                                    )]['websiteUrl'],
                                initialColorIndex:
                                    displayJobs[_idx(
                                      0,
                                      displayJobs.length,
                                    )]['initialColorIndex'],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom nav space (you can add navigation here if needed)
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat List')),
      body: Center(child: Text('Chat List Screen')),
    );
  }
}
