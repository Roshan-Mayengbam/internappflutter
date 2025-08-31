import 'package:flutter/material.dart';
import 'job_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> jobs = [
    {
      'jobTitle': 'UI/UX Designer',
      'companyName': 'Lumel Technologies',
      'location': 'Chennai',
      'experienceLevel': '0-2 years',
      'requirements': [
        '0 - 3 year experience',
        'Strong design fundamentals',
        'Knowledge of Figma',
      ],
      'websiteUrl': 'www.lumel.com',
      'initialColorIndex': 0,
    },
    {
      'jobTitle': 'Frontend Developer',
      'companyName': 'Pixel Labs',
      'location': 'Bangalore',
      'experienceLevel': '0-2 years',
      'requirements': ['React, Flutter', 'UI/UX skills', 'Team player'],
      'websiteUrl': 'www.pixellabs.com',
      'initialColorIndex': 1,
    },
    {
      'jobTitle': 'Backend Developer',
      'companyName': 'Tech Corp',
      'location': 'Remote',
      'experienceLevel': '1-3 years',
      'requirements': ['1+ year experience', 'Node.js, MongoDB', 'REST APIs'],
      'websiteUrl': 'www.techcorp.com',
      'initialColorIndex': 2,
    },
  ];

  // Which card is currently on top
  int _topIndex = 0;

  // Live drag progress to animate the stack (0.0 -> 1.0)
  double _dragProgress = 0.0;
  DismissDirection? _dragDirection;

  int _idx(int offset) => (_topIndex + offset) % jobs.length;

  @override
  Widget build(BuildContext context) {
    const cardWidth = 320.0;
    const cardHeight = 480.0; // Increased from 400.0 to 480.0

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
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.notifications_none,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

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
                            child: _JobItem(job: jobs[_idx(2)], fixedIndex: 2),
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
                            child: _JobItem(job: jobs[_idx(1)], fixedIndex: 1),
                          ),
                        ),
                      ),

                      // Top card (swipe with Dismissible)
                      Transform.rotate(
                        angle: topAngle,
                        child: Dismissible(
                          key: ValueKey('job_${_idx(0)}_$_topIndex'),
                          direction: DismissDirection.horizontal,
                          dismissThresholds: const {
                            DismissDirection.startToEnd: 0.35,
                            DismissDirection.endToStart: 0.35,
                          },
                          onUpdate: (details) {
                            setState(() {
                              _dragProgress = details.progress.clamp(0.0, 1.0);
                              _dragDirection = details.direction;
                            });
                          },
                          onDismissed: (_) {
                            setState(() {
                              _dragProgress = 0.0;
                              _dragDirection = null;
                              _topIndex = (_topIndex + 1) % jobs.length;
                            });
                          },
                          confirmDismiss: (direction) async {
                            // allow both left/right swipes
                            return true;
                          },
                          child: _JobItem(job: jobs[_idx(0)], fixedIndex: 0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom nav
          ],
        ),
      ),
    );
  }
}

class _JobItem extends StatelessWidget {
  final Map<String, dynamic> job;
  final int fixedIndex; // just to pass an initialColorIndex reliably

  const _JobItem({required this.job, required this.fixedIndex});

  @override
  Widget build(BuildContext context) {
    return JobCard(
      jobTitle: job['jobTitle'],
      companyName: job['companyName'],
      location: job['location'],
      experienceLevel: job['experienceLevel'],
      requirements: List<String>.from(job['requirements']),
      websiteUrl: job['websiteUrl'],
      initialColorIndex: job['initialColorIndex'] ?? fixedIndex,
    );
  }
}
