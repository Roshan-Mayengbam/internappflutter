import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:internappflutter/auth/google_signin.dart';
import 'package:internappflutter/auth/registerpage.dart';
import 'package:internappflutter/bottomnavbar.dart';
import 'package:internappflutter/models/usermodel.dart';

class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  final GoogleAuthService _authService = GoogleAuthService();
  bool _isLoading = false;

  /// 🔎 Debug helper for image assets
  Widget debugAsset(String path, {double? width, double? height}) {
    return Image.asset(
      path,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        print("❌ Failed to load image: $path");
        return Icon(Icons.error, color: Colors.red, size: 40);
      },
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.signInWithGoogle();

      if (user != null) {
        print("🔐 User signed in successfully: ${user.email}");

        // Check if user exists in database
        final checkResult = await _authService.checkIfUserExists();
        print("🔍 CHECK RESULT: $checkResult");

        if (checkResult != null) {
          final exists = checkResult['exists'];
          print("🔍 User exists in database: $exists");

          if (exists == true) {
            // User exists in database - go to home page
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
            // User doesn't exist in database - go to registration
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
            // Unexpected value
            print("❌ Unexpected exists value: $exists");
            await _authService.signOut();
            _showErrorSnackBar("Authentication error. Please try again.");
          }
        } else {
          print("❌ Failed to check user status");
          await _authService.signOut();
          _showErrorSnackBar("Unable to verify account. Please try again.");
        }
      } else {
        print("❌ Google sign-in failed");
        _showErrorSnackBar("Sign-in failed. Please try again.");
      }
    } catch (e) {
      print("❌ Sign-in exception: $e");
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
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(250, 226, 253, 223),
      body: Stack(
        children: [
          Positioned(
            right: 0,
            top: 44,
            child: debugAsset('assets/images/2image1.png'),
          ),
          Positioned(
            top: 79,
            left: 0,
            child: debugAsset('assets/images/girl.png'),
          ),
          Positioned(
            top: 100,
            right: 20,
            child: debugAsset('assets/images/2text2.png'),
          ),
          Positioned(
            top: 412,
            left: 16,
            child: debugAsset('assets/images/JUMP.png'),
          ),
          Positioned(
            top: 496,
            left: 73,
            child: debugAsset('assets/images/IN.png'),
          ),
          Positioned(
            top: 562,
            left: 16,
            child: debugAsset('assets/images/YOUR.png'),
          ),
          Positioned(
            top: 627,
            left: 16,
            child: debugAsset('assets/images/DREAMS.png'),
          ),
          Positioned(
            top: 490,
            left: 150,
            child: debugAsset('assets/images/Star2.png'),
          ),
          Positioned(
            top: 487,
            left: 236,
            child: debugAsset('assets/images/TO.png'),
          ),
          Positioned(
            top: 737,
            left: 16,
            child: debugAsset('assets/images/2image1.png'),
          ),

          // Google Sign-In button
          Positioned(
            top: 795,
            left: 16,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isLoading ? null : _handleGoogleSignIn,
                child: Stack(
                  children: [
                    debugAsset('assets/images/union1.png'),
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

          Positioned(
            top: 813,
            left: 135,
            child: debugAsset('assets/images/cwg.png'),
          ),
          Positioned(
            top: 813,
            left: 35,
            child: InkWell(
              onTap: _isLoading ? null : _handleGoogleSignIn,
              child: debugAsset('assets/images/google.png'),
            ),
          ),

          Positioned(
            top: 800,
            left: 340,
            child: IconButton(
              iconSize: 100,
              onPressed: () {
                print("➡️ Arrow pressed!");
              },
              icon: debugAsset("assets/images/arrow_outward.png"),
            ),
          ),
        ],
      ),
    );
  }
}
