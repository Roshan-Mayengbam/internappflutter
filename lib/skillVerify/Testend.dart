import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class TestSuccessPage extends StatefulWidget {
  final String userskill;
  // ignore: non_constant_identifier_names
  final String TestResult;
  final String userlevel;
  const TestSuccessPage({
    Key? key,
    required this.userskill,
    required this.TestResult,
    required this.userlevel,
  }) : super(key: key);

  @override
  State<TestSuccessPage> createState() => _TestSuccessPageState();
}

class _TestSuccessPageState extends State<TestSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isUpdating = false;
  bool _updateSuccess = false;

  @override
  void initState() {
    super.initState();
    print(widget.TestResult);
    print(widget.userlevel);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();

    // Auto-update skill if passed
    if (int.parse(widget.TestResult) >= 7) {
      _updateSkillLevel();
    }
  }

  Future<void> _updateSkillLevel() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      // Get Firebase ID token
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final idToken = await user.getIdToken();

      // API endpoint - replace with your actual backend URL
      const String apiUrl = 'https://hyrup-730899264601.asia-south1.run.app';

      print('Sending request to: $apiUrl');
      print('Skill: ${widget.userskill}, Level: ${widget.userlevel}');

      final response = await http
          .put(
            Uri.parse(apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $idToken',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'skillName': widget.userskill,
              'level': widget.userlevel,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _updateSuccess = true;
          _isUpdating = false;
        });
        print('Skill level updated successfully');
      } else {
        throw Exception(
          'Failed to update skill (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      print('Error updating skill level: $e');
      setState(() {
        _isUpdating = false;
      });

      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update skill level'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _updateSkillLevel,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool passed = int.parse(widget.TestResult) >= 7;

    return Scaffold(
      backgroundColor: passed
          ? const Color(0xFF4ADE80)
          : const Color(0xFFEF5350),
      body: SafeArea(
        child: Stack(
          children: [
            // Confetti particles (only show if passed)
            if (passed) ...List.generate(30, (index) => _buildConfetti(index)),

            // Main content
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.userskill} Test',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '100% Complete',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: passed
                                    ? const Color(0xFF4ADE80)
                                    : const Color(0xFFEF5350),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Success/Failure message
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      passed
                          ? 'Successfully Completed\nYour ${widget.userskill} Test — ✅ Pass'
                          : 'Try again next time\nKeep practicing!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Update status indicator (only show when passed and updating)
                if (passed && _isUpdating)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Updating skill level...',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),

                if (passed && _updateSuccess)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.black,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Skill verified as ${widget.userlevel}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Trophy/Failure animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Lottie.asset(
                      passed
                          ? 'assets/animations/Trophy animation.json'
                          : 'assets/animations/Stressed Woman at work.json',
                      fit: BoxFit.contain,
                      frameRate: FrameRate.max,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Score
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    '${widget.TestResult}/10',
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),

                const Spacer(),

                // Go to Home button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Go to Home',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Retry button (only show if failed)
                if (!passed)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Try Again',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfetti(int index) {
    final random = math.Random(index);
    final left = random.nextDouble() * 400;
    final top = random.nextDouble() * 900;
    final rotation = random.nextDouble() * 360;
    final size = random.nextDouble() * 20 + 10;

    final shapes = [
      Icons.star,
      Icons.circle,
      Icons.square,
      Icons.change_history,
    ];

    final colors = [
      const Color(0xFFFFA726),
      const Color(0xFFEF5350),
      const Color(0xFF42A5F5),
      const Color(0xFFAB47BC),
      const Color(0xFFFFEE58),
    ];

    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: rotation * math.pi / 180,
        child: Icon(
          shapes[random.nextInt(shapes.length)],
          color: colors[random.nextInt(colors.length)],
          size: size,
        ),
      ),
    );
  }
}
