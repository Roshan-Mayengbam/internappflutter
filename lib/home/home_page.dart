import 'package:flutter/material.dart';
import 'job_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
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

  int _idx(int offset) => (_topIndex + offset) % jobs.length;

  @override
  void initState() {
    super.initState();
    _initAnimations();
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
    final cardWidth = screenSize.width - 40.0; // Full width minus padding
    final cardHeight = screenSize.height * 0.50; // 50% of screen height

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
                      key: Key(notifications['msg'][index] + index.toString()),
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
                            child: JobCard(
                              jobTitle: jobs[_idx(2)]['jobTitle'],
                              companyName: jobs[_idx(2)]['companyName'],
                              location: jobs[_idx(2)]['location'],
                              experienceLevel: jobs[_idx(2)]['experienceLevel'],
                              requirements: List<String>.from(
                                jobs[_idx(2)]['requirements'],
                              ),
                              websiteUrl: jobs[_idx(2)]['websiteUrl'],
                              initialColorIndex:
                                  jobs[_idx(2)]['initialColorIndex'],
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
                              jobTitle: jobs[_idx(1)]['jobTitle'],
                              companyName: jobs[_idx(1)]['companyName'],
                              location: jobs[_idx(1)]['location'],
                              experienceLevel: jobs[_idx(1)]['experienceLevel'],
                              requirements: List<String>.from(
                                jobs[_idx(1)]['requirements'],
                              ),
                              websiteUrl: jobs[_idx(1)]['websiteUrl'],
                              initialColorIndex:
                                  jobs[_idx(1)]['initialColorIndex'],
                            ),
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
                          child: JobCard(
                            jobTitle: jobs[_idx(0)]['jobTitle'],
                            companyName: jobs[_idx(0)]['companyName'],
                            location: jobs[_idx(0)]['location'],
                            experienceLevel: jobs[_idx(0)]['experienceLevel'],
                            requirements: List<String>.from(
                              jobs[_idx(0)]['requirements'],
                            ),
                            websiteUrl: jobs[_idx(0)]['websiteUrl'],
                            initialColorIndex:
                                jobs[_idx(0)]['initialColorIndex'],
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
  }
}
