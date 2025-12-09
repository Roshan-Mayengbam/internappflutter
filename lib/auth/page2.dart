import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:internappflutter/auth/registerpage.dart';

import '../bottomnavbar.dart';
import '../models/usermodel.dart';
import 'google_signin.dart';

class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  final GoogleAuthService _authService = GoogleAuthService();
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.signInWithGoogle();

      if (user != null) {
        if (kDebugMode) print("🔐 User signed in successfully: ${user.email}");

        // Dummy implementation for check, replace with actual logic
        // This is where you connect to your database (Firestore/Supabase/etc.)
        final checkResult = await _authService.checkIfUserExists();

        if (checkResult != null) {
          final exists = checkResult['exists'];

          if (exists == true) {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) =>
                      BottomnavbarAlternative(userData: checkResult['user']),
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Welcome back!"),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } else if (exists == false) {
            final userModel = UserModel(
              name: user.displayName ?? 'Unknown User',
              email: user.email ?? 'No Email',
              phone: '',
              uid: user.uid,
              role: 'Student',
            );

            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => RegisterPage(userModel: userModel),
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please complete your registration"),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          } else {
            await _authService.signOut();
            _showErrorSnackBar("Authentication error. Please try again.");
          }
        } else {
          await _authService.signOut();
          _showErrorSnackBar("Unable to verify account. Please try again.");
        }
      } else {
        _showErrorSnackBar("Sign-in failed. Please try again.");
      }
    } catch (e) {
      if (kDebugMode) print("❌ Sign-in exception: $e");
      await _authService.signOut();
      _showErrorSnackBar("Sign-in error: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions once for cleaner code
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(250, 226, 253, 223),
      body: Stack(
        children: [
          // --- Decorative Elements (Top Right) ---
          Positioned(
            right: 0,
            // 5% from the top
            top: screenHeight * 0.1,
            child: Image.asset(
              'assets/images/2image1.png',
              // Constraint max height to 10% of screen
              height: screenHeight * 0.22,
            ),
          ),

          // 🌟 PROMINENT GIRL.PNG 🌟
          Positioned(
            // 10% from the top
            top: screenHeight * 0.2,
            left: 0,
            child: Image.asset(
              'assets/images/girl.png',
              // Increased height constraint to 50% of screen height
              height: screenHeight * 0.6,
              fit: BoxFit.contain,
            ),
          ),

          Positioned(
            top: screenHeight * 0.16,
            right: screenWidth * 0.05,
            child: Image.asset(
              'assets/images/2text2.png',
              // Constraint max height to 10% of screen
              height: screenHeight * 0.1,
            ),
          ),

          // --- Text Elements (JUMP IN YOUR DREAMS) ---
          // The text elements are shifted down slightly to accommodate the larger girl image.

          // JUMP - Start at 55% height (moved from 50%)
          Positioned(
            top: screenHeight * 0.55,
            left: screenWidth * 0.04,
            child: Image.asset(
              'assets/images/JUMP.png',
              height:
                  screenHeight *
                  0.06, // Slight reduction in size for better fit
            ),
          ),
          // IN
          Positioned(
            top: screenHeight * 0.62, // Adjusted
            left: screenWidth * 0.18,
            child: Image.asset(
              'assets/images/IN.png',
              height:
                  screenHeight *
                  0.06, // Slight reduction in size for better fit
            ),
          ),
          // YOUR
          Positioned(
            top: screenHeight * 0.69, // Adjusted
            left: screenWidth * 0.04,
            child: Image.asset(
              'assets/images/YOUR.png',
              height:
                  screenHeight *
                  0.06, // Slight reduction in size for better fit
            ),
          ),
          // DREAMS
          Positioned(
            top: screenHeight * 0.76, // Adjusted
            left: screenWidth * 0.04,
            child: Image.asset(
              'assets/images/DREAMS.png',
              height: screenHeight * 0.07,
            ),
          ),

          // TO (positioned next to IN)
          Positioned(
            top: screenHeight * 0.61, // Adjusted
            left: screenWidth * 0.55,
            child: Image.asset(
              'assets/images/TO.png',
              height: screenHeight * 0.08,
            ),
          ),
          // Star2
          Positioned(
            top: screenHeight * 0.62, // Adjusted
            left: screenWidth * 0.40,
            child: Image.asset(
              'assets/images/Star2.png',
              height: screenHeight * 0.06, // Slight reduction
            ),
          ),

          // --- Sign-In Button (Bottom Area) ---
          Positioned(
            // Constraint from the bottom
            bottom: screenHeight * 0.08,
            left: screenWidth * 0.04, // 4% padding
            right: screenWidth * 0.04, // 4% padding
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isLoading ? null : _handleGoogleSignIn,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Base Image (union1.png) - Scales with width
                    Image.asset(
                      'assets/images/union1.png',
                      fit: BoxFit.fitWidth,
                    ),

                    // Button Contents (Centered)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Google Icon
                          Image.asset(
                            'assets/images/google.png',
                            height: screenHeight * 0.04,
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          // Text 'cwg.png'
                          Image.asset(
                            'assets/images/cwg.png',
                            height: screenHeight * 0.03,
                          ),
                          // Arrow - positioned to the right end
                          const Spacer(),
                          if (!_isLoading)
                            Image.asset(
                              "assets/images/arrow_outward.png",
                              height: screenHeight * 0.05,
                            ),
                        ],
                      ),
                    ),

                    // Show loading indicator if signing in
                    if (_isLoading)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
