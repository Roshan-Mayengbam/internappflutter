import 'package:flutter/material.dart';
import 'job_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
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
      'requirements': [
        'React, Flutter',
        'UI/UX skills',
        'Team player',
      ],
      'websiteUrl': 'www.pixellabs.com',
      'initialColorIndex': 1,
    },
    {
      'jobTitle': 'Backend Developer',
      'companyName': 'Tech Corp',
      'location': 'Remote',
      'experienceLevel': '1-3 years',
      'requirements': [
        '1+ year experience',
        'Node.js, MongoDB',
        'REST APIs',
      ],
      'websiteUrl': 'www.techcorp.com',
      'initialColorIndex': 2,
    },
  ];

  late AnimationController _controller;
  late Animation<Offset> _swipeAnimation;
  Offset _dragOffset = Offset.zero;
  double _dragRotation = 0.0;
  bool _isDragging = false;

  bool _isAnimatingOut = false;
  Offset _outgoingOffset = Offset.zero;
  double _outgoingRotation = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _swipeAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_controller)
      ..addListener(() {
        setState(() {
          if (_isAnimatingOut) {
            _outgoingOffset = _swipeAnimation.value;
          } else {
            _dragOffset = _swipeAnimation.value;
          }
        });
      });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isAnimatingOut) {
        //Reset outgoing card's position
        setState(() {
          _outgoingOffset = Offset.zero;
          _outgoingRotation = 0.0;
          _dragOffset = Offset.zero;
          _dragRotation = 0.0;
          _isDragging = false;
          _isAnimatingOut = false;
        });
        // Update the stack in the next frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            final removed = jobs.removeAt(0);
            jobs.add(removed);
          });
        });
        _controller.reset();
      } else if (status == AnimationStatus.completed) {
        setState(() {
          _dragOffset = Offset.zero;
          _dragRotation = 0.0;
          _isDragging = false;
        });
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
      _dragRotation = _dragOffset.dx / 300;
      _isDragging = true;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final shouldSwipe = _dragOffset.dx.abs() > screenWidth * 0.25 || _dragOffset.dy.abs() > 150;
    if (shouldSwipe) {
      final endOffset = Offset(
        _dragOffset.dx > 0 ? screenWidth : -screenWidth,
        _dragOffset.dy,
      );
      _isAnimatingOut = true;
      _outgoingOffset = _dragOffset;
      _outgoingRotation = _dragRotation;
      _swipeAnimation = Tween<Offset>(begin: _dragOffset, end: endOffset).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ));
      _controller.forward(from: 0);
    } else {
      // Animate back to center
      _swipeAnimation = Tween<Offset>(begin: _dragOffset, end: Offset.zero).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = 320.0;
    final cardHeight = 400.0;

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
                        child: const Icon(Icons.notifications_none, color: Colors.black),
                      ),
                      const SizedBox(width: 12),
                     
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.chat_bubble_outline, color: Colors.black),
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
            Expanded(
              child: Center(
                child: SizedBox(
                  width: cardWidth,
                  height: cardHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 3rd card 
                      Transform.scale(
                        scale: _isDragging ? 0.95 : 0.9,
                        child: Transform.translate(
                          offset: _isDragging ? const Offset(0, 32) : const Offset(0, 48),
                          child: Transform.rotate(
                            angle: 0.2,
                            alignment: Alignment.bottomRight,
                            child: JobCard(
                              jobTitle: jobs[2]['jobTitle'],
                              companyName: jobs[2]['companyName'],
                              location: jobs[2]['location'],
                              experienceLevel: jobs[2]['experienceLevel'],
                              requirements: List<String>.from(jobs[2]['requirements']),
                              websiteUrl: jobs[2]['websiteUrl'],
                              initialColorIndex: 2, 
                            ),
                          ),
                        ),
                      ),
                      // 2nd card 
                      Transform.scale(
                        scale: _isDragging ? 0.98 : 0.95,
                        child: Transform.translate(
                          offset: _isDragging ? const Offset(0, 16) : const Offset(0, 24),
                          child: Transform.rotate(
                            angle: 0.1,
                            alignment: Alignment.bottomRight,
                            child: JobCard(
                              jobTitle: jobs[1]['jobTitle'],
                              companyName: jobs[1]['companyName'],
                              location: jobs[1]['location'],
                              experienceLevel: jobs[1]['experienceLevel'],
                              requirements: List<String>.from(jobs[1]['requirements']),
                              websiteUrl: jobs[1]['websiteUrl'],
                              initialColorIndex: 1, 
                            ),
                          ),
                        ),
                      ),
                      // Top card (draggable or animating out)
                      if (_isAnimatingOut)
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: _outgoingOffset,
                              child: Transform.rotate(
                                angle: _outgoingRotation,
                                child: JobCard(
                                  jobTitle: jobs[0]['jobTitle'],
                                  companyName: jobs[0]['companyName'],
                                  location: jobs[0]['location'],
                                  experienceLevel: jobs[0]['experienceLevel'],
                                  requirements: List<String>.from(jobs[0]['requirements']),
                                  websiteUrl: jobs[0]['websiteUrl'],
                                  initialColorIndex: 0, 
                                ),
                              ),
                            );
                          },
                        )
                      else
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: _dragOffset,
                              child: Transform.rotate(
                                angle: _dragRotation,
                                child: GestureDetector(
                                  onPanUpdate: _onPanUpdate,
                                  onPanEnd: _onPanEnd,
                                  child: JobCard(
                                    jobTitle: jobs[0]['jobTitle'],
                                    companyName: jobs[0]['companyName'],
                                    location: jobs[0]['location'],
                                    experienceLevel: jobs[0]['experienceLevel'],
                                    requirements: List<String>.from(jobs[0]['requirements']),
                                    websiteUrl: jobs[0]['websiteUrl'],
                                    initialColorIndex: 0,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom navigation bar
            Padding(
              padding: const EdgeInsets.only(bottom: 18.0),
              child: Center(
                child: Container(
                  
                  width: 220,
                  height: 56,
                  decoration: BoxDecoration(
                    
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Icon(Icons.home, color: Color(0xFF4BFF3D), size: 30),
                      Icon(Icons.bookmark_border, color: Colors.black, size: 28),
                      Icon(Icons.calendar_today_outlined, color: Colors.black, size: 28),
                      Icon(Icons.person_outline, color: Colors.black, size: 28),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}