import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internappflutter/auth/courserange.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ✅ FIXED: Use /student prefix to match your backend setup
  static const String baseUrl =
      "https://hyrup-730899264601.asia-south1.run.app/student";

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        if (kDebugMode) print("❌ User cancelled Google sign-in");
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        if (kDebugMode) print("✅ User signed in successfully:");
        if (kDebugMode) print("Name: ${user.displayName}");
        if (kDebugMode) print("Email: ${user.email}");
        if (kDebugMode) print("UID: ${user.uid}");
        return user;
      }
      return null;
    } catch (e) {
      if (kDebugMode) print("❌ Google Sign-In error: $e");
      await signOut();
      return null;
    }
  }

  // ✅ FIXED: Now calls /student/check to match your backend
  Future<Map<String, dynamic>?> checkIfUserExists() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        if (kDebugMode) print("❌ No authenticated user found");
        return null;
      }

      if (kDebugMode) print("🔑 Getting ID token...");
      final idToken = await currentUser.getIdToken();
      if (kDebugMode) print("✅ ID token obtained");

      if (kDebugMode) print("🔍 Calling: $baseUrl/check");
      if (kDebugMode) print("🔑 Using UID: ${currentUser.uid}");

      final response = await http
          .get(
            Uri.parse("$baseUrl/check"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $idToken",
            },
          )
          .timeout(Duration(seconds: 30));

      if (kDebugMode) {
        print("📡 Backend response status: ${response.statusCode}");
      }
      if (kDebugMode) print("📄 Backend response body: ${response.body}");

      // ✅ Handle 200 - User exists
      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          if (kDebugMode) print("📄 Parsed response data: $responseData");
          if (kDebugMode) {
            print("📄 Response keys: ${responseData.keys.toList()}");
          }
          if (kDebugMode) print("📄 'exists' value: ${responseData['exists']}");
          if (kDebugMode) {
            print("📄 'exists' type: ${responseData['exists'].runtimeType}");
          }

          if (responseData.containsKey('exists')) {
            if (responseData['exists'] == true &&
                responseData.containsKey('user')) {
              if (kDebugMode) {
                print("✅ User exists in database - has user data");
              }
              return {"exists": true, "user": responseData['user']};
            } else if (responseData['exists'] == false) {
              if (kDebugMode) print("👤 User does not exist in database");
              return {"exists": false};
            } else {
              if (kDebugMode) {
                print("❌ Unexpected exists value: ${responseData['exists']}");
              }
              return null;
            }
          } else {
            if (kDebugMode) print("❌ Response missing 'exists' field");
            return null;
          }
        } catch (parseError) {
          if (kDebugMode) print("❌ JSON parsing error: $parseError");
          if (kDebugMode) print("❌ Raw response: ${response.body}");
          return null;
        }
      }
      // ✅ Handle 404 - User not found (this is what you're getting)
      else if (response.statusCode == 404) {
        try {
          final responseData = jsonDecode(response.body);
          if (kDebugMode) print("👤 User not found in database (404)");
          if (kDebugMode) print("📄 Message: ${responseData['message']}");
          // Return exists: false to trigger registration flow
          return {"exists": false};
        } catch (parseError) {
          if (kDebugMode) print("❌ JSON parsing error on 404: $parseError");
          // Still return exists: false even if parsing fails
          return {"exists": false};
        }
      }
      // ❌ Handle other status codes
      else {
        if (kDebugMode) {
          print("❌ Unexpected status code: ${response.statusCode}");
        }
        if (kDebugMode) print("❌ Response body: ${response.body}");
        return null;
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error checking user: $e");
      if (e.toString().contains('TimeoutException')) {
        if (kDebugMode) print("❌ Request timed out - check server connection");
      }
      return null;
    }
  }

  // ✅ FIXED: Now calls /student/signup to match your backend
  Future<bool> submitCompleteUserData(
    FinalUserModel userModel,
    File? profileImage,
  ) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        if (kDebugMode) print("❌ No authenticated user found");
        return false;
      }

      final idToken = await currentUser.getIdToken();

      final requestBody = {
        "phone": userModel.phone,
        "profile": {
          "firstName": userModel.name.split(" ").first,
          "lastName": userModel.name.split(" ").length > 1
              ? userModel.name.split(" ").skip(1).join(" ")
              : "",
        },
        "education": {
          "college": userModel.collegeName,
          "degree": userModel.degree,
          "branch": userModel.degree,
          "graduationYear": _extractGraduationYear(userModel.courseRange),
        },
      };

      // ✅ This will call: http://10.207.242.157:3000/student/signup
      if (kDebugMode) print("📤 Calling: $baseUrl/signup");
      if (kDebugMode) print("📄 Request body: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse("$baseUrl/signup"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
        body: jsonEncode(requestBody),
      );

      if (kDebugMode) {
        print("📡 Backend response status: ${response.statusCode}");
      }
      if (kDebugMode) print("📄 Backend response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (kDebugMode) print("✅ User data submitted successfully");
        return true;
      } else {
        if (kDebugMode) {
          print("❌ Backend submission failed: ${response.statusCode}");
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error submitting user data: $e");
      return false;
    }
  }

  int? _extractGraduationYear(String courseRange) {
    try {
      if (courseRange.contains('-')) {
        final parts = courseRange.split('-');
        if (parts.length == 2) {
          return int.parse(parts[1]);
        }
      } else if (courseRange.contains('+')) {
        final year = courseRange.replaceAll('+', '');
        final baseYear = int.parse(year);
        return baseYear + 4;
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error parsing course range: $e");
    }
    return null;
  }

  Future<void> signOut() async {
    try {
      if (kDebugMode) print("🚪 Signing out user...");
      await _googleSignIn.signOut();
      await _auth.signOut();
      if (kDebugMode) print("✅ User signed out successfully");
    } catch (e) {
      if (kDebugMode) print("❌ Sign out error: $e");
    }
  }

  User? getCurrentUser() => _auth.currentUser;
  bool isSignedIn() => _auth.currentUser != null;
}
