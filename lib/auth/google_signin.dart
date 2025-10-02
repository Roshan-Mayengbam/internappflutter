import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internappflutter/auth/courserange.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ✅ FIXED: Use /student prefix to match your backend setup
  static const String baseUrl = "http://192.168.8.161:3000/student";

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("❌ User cancelled Google sign-in");
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
        print("✅ User signed in successfully:");
        print("Name: ${user.displayName}");
        print("Email: ${user.email}");
        print("UID: ${user.uid}");
        return user;
      }
      return null;
    } catch (e) {
      print("❌ Google Sign-In error: $e");
      await signOut();
      return null;
    }
  }

  // ✅ FIXED: Now calls /student/check to match your backend
  Future<Map<String, dynamic>?> checkIfUserExists() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print("❌ No authenticated user found");
        return null;
      }

      print("🔑 Getting ID token...");
      final idToken = await currentUser.getIdToken();
      print("✅ ID token obtained");

      print("🔍 Calling: $baseUrl/check");
      print("🔑 Using UID: ${currentUser.uid}");

      final response = await http
          .get(
            Uri.parse("$baseUrl/check"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $idToken",
            },
          )
          .timeout(Duration(seconds: 30));

      print("📡 Backend response status: ${response.statusCode}");
      print("📄 Backend response body: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          print("📄 Parsed response data: $responseData");
          print("📄 Response keys: ${responseData.keys.toList()}");
          print("📄 'exists' value: ${responseData['exists']}");
          print("📄 'exists' type: ${responseData['exists'].runtimeType}");

          // ✅ CRITICAL FIX: Check the 'exists' field from backend response
          if (responseData.containsKey('exists')) {
            if (responseData['exists'] == true &&
                responseData.containsKey('user')) {
              print("✅ User exists in database - has user data");
              return {"exists": true, "user": responseData['user']};
            } else if (responseData['exists'] == false) {
              print("👤 User does not exist in database");
              return {"exists": false};
            } else {
              print("❌ Unexpected exists value: ${responseData['exists']}");
              return null;
            }
          } else {
            print("❌ Response missing 'exists' field");
            return null;
          }
        } catch (parseError) {
          print("❌ JSON parsing error: $parseError");
          print("❌ Raw response: ${response.body}");
          return null;
        }
      } else {
        print("❌ Unexpected status code: ${response.statusCode}");
        print("❌ Response body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error checking user: $e");
      if (e.toString().contains('TimeoutException')) {
        print("❌ Request timed out - check server connection");
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
        print("❌ No authenticated user found");
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
      print("📤 Calling: $baseUrl/signup");
      print("📄 Request body: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse("$baseUrl/signup"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
        body: jsonEncode(requestBody),
      );

      print("📡 Backend response status: ${response.statusCode}");
      print("📄 Backend response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ User data submitted successfully");
        return true;
      } else {
        print("❌ Backend submission failed: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Error submitting user data: $e");
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
      print("❌ Error parsing course range: $e");
    }
    return null;
  }

  Future<void> signOut() async {
    try {
      print("🚪 Signing out user...");
      await _googleSignIn.signOut();
      await _auth.signOut();
      print("✅ User signed out successfully");
    } catch (e) {
      print("❌ Sign out error: $e");
    }
  }

  User? getCurrentUser() => _auth.currentUser;
  bool isSignedIn() => _auth.currentUser != null;
}
