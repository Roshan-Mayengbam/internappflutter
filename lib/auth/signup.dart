import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isLoading = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '494653563380-ukls9bl3snhfs08u1loiqn5a4f1boskd.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  // Check if Google Play Services is available
  Future<bool> _checkPlayServicesAvailability() async {
    try {
      // Try to check if already signed in (this will fail if Play Services unavailable)
      final bool isSignedIn = await _googleSignIn.isSignedIn();
      return true; // If we get here, Play Services is available
    } catch (e) {
      print('Play Services check failed: $e');
      return false;
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('Starting Google Sign-In...');

      // Check Play Services availability first
      final bool playServicesAvailable = await _checkPlayServicesAvailability();

      if (!playServicesAvailable) {
        _showSnackBar(
          'Google Play Services is not available on this device. Please use a device with Google Play Services or try on a physical device.',
          isError: true,
          duration: 5,
        );
        return;
      }

      // Only sign out if Play Services is available
      try {
        await _googleSignIn.signOut();
      } catch (signOutError) {
        print('Sign out error (continuing anyway): $signOutError');
        // Continue with sign in even if sign out fails
      }

      // Then sign in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print('Sign-in result: $googleUser');

      if (googleUser == null) {
        _showSnackBar('Sign-in was cancelled');
        return;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print(
        'Access token: ${googleAuth.accessToken != null ? 'Present' : 'Missing'}',
      );
      print('ID token: ${googleAuth.idToken != null ? 'Present' : 'Missing'}');

      // Extract user information
      final String username = googleUser.displayName ?? '';
      final String email = googleUser.email;
      final String profilePicUrl = googleUser.photoUrl ?? '';
      final String googleId = googleUser.id;

      print('Username: $username');
      print('Email: $email');
      print('Profile Picture URL: $profilePicUrl');
      print('Google ID: $googleId');

      // Navigate to confirmation screen with user data
      Navigator.pushNamed(
        context,
        '/signup/confirmation',
        arguments: {
          'username': username,
          'email': email,
          'profilePicUrl': profilePicUrl,
          'googleId': googleId,
          'accessToken': googleAuth.accessToken,
          'idToken': googleAuth.idToken,
        },
      );
    } catch (error) {
      print('Google Sign-In Error: $error');
      print('Error type: ${error.runtimeType}');

      // More specific error handling
      if (error.toString().contains('12500')) {
        _showSnackBar(
          'Configuration error. Please check SHA-1 fingerprint.',
          isError: true,
        );
      } else if (error.toString().contains('10') ||
          error.toString().contains('SERVICE_INVALID') ||
          error.toString().contains('Google Play Store')) {
        _showSnackBar(
          'Google Play Services not available. Please use a device with Google Play Services.',
          isError: true,
          duration: 4,
        );
      } else if (error.toString().contains('sign_in_failed')) {
        _showSnackBar('Sign-in failed. Please try again.', isError: true);
      } else {
        _showSnackBar(
          'Failed to sign in with Google: ${error.toString()}',
          isError: true,
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Enhanced function to show snackbar messages
  void _showSnackBar(String message, {bool isError = false, int duration = 3}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red.shade600 : null,
        duration: Duration(seconds: duration),
      ),
    );
  }

  // Function to sign out (for testing purposes)
  Future<void> _handleGoogleSignOut() async {
    try {
      await _googleSignIn.signOut();
      _showSnackBar('Signed out successfully');
    } catch (error) {
      print('Sign out error: $error');
      _showSnackBar('Sign out failed: $error', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade50, Colors.grey.shade100],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade100,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.work_outline,
                      color: Colors.blue.shade700,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Heading
                  Text(
                    "Join Our Community",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Find your perfect job match",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 40),

                  _buildAuthButton(
                    icon: Icons.mail_outline,
                    text: "Continue with Email",
                    color: Colors.blue.shade700,
                    textColor: Colors.white,
                    onPressed: () {
                      // Navigate to email signup screen
                      Navigator.pushNamed(context, '/signup/email');
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildAuthButton(
                    icon: Icons.phone_android,
                    text: "Continue with Phone",
                    color: Colors.green.shade600,
                    textColor: Colors.white,
                    onPressed: () {
                      // Navigate to phone signup screen
                      Navigator.pushNamed(context, '/signup/phone');
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.grey.shade800,
                        side: BorderSide.none,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _isLoading ? null : _handleGoogleSignIn,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  "https://cdn1.iconfinder.com/data/icons/google-s-logo/150/Google_Icons-09-512.png",
                                  height: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text("Continue with Google"),
                              ],
                            ),
                    ),
                  ),

                  // Debug: Sign out button (remove in production)
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _handleGoogleSignOut,
                    child: Text(
                      "Sign Out (Debug)",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),

                  // Helper text for testing
                  const SizedBox(height: 20),
                  Text(
                    "Note: Google Sign-In requires Google Play Services.\nTest on a physical device or emulator with Google Play.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthButton({
    required IconData icon,
    required String text,
    required Color color,
    Color textColor = Colors.white,
    VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
