import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      // ✅ Send user data to backend and check if successful
      if (user != null) {
        final idToken = await user.getIdToken(); // Firebase token

        try {
          final response = await http.post(
            Uri.parse("http://10.180.215.157:3000/student/signup"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $idToken", // send token
            },
            body: jsonEncode({
              "phone": user.phoneNumber,
              "profilePicture": user.photoURL,
              "displayName": user.displayName,
            }),
          );

          print("Backend response: ${response.body}");

          // ✅ Check if backend registration was successful
          if (response.statusCode == 200 || response.statusCode == 201) {
            // Success - return user
            return user;
          } else {
            // Backend failed - sign out from Firebase and Google
            print("Backend signup failed with status: ${response.statusCode}");
            await signOut();
            return null;
          }
        } catch (e) {
          // Network error or other backend issues
          print("Backend request error: $e");
          await signOut();
          return null;
        }
      }

      return null;
    } catch (e) {
      print("Google Sign-In error: $e");
      // Make sure to sign out if there's any error
      await signOut();
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print("Sign out error: $e");
    }
  }
}
