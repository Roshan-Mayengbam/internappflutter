import 'package:firebase_auth/firebase_auth.dart';

class FirebaseOTPService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  int? _resendToken;

  // Send OTP to phone number
  Future<bool> sendOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
    Function(PhoneAuthCredential)? onVerificationCompleted,
    Function()? onVerificationFailed,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed (happens on some Android devices)
          if (onVerificationCompleted != null) {
            onVerificationCompleted(credential);
          } else {
            await _signInWithCredential(credential);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (onVerificationFailed != null) {
            onVerificationFailed();
          }
          onError('Verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent('OTP sent successfully');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
      );
      return true;
    } catch (e) {
      onError('Failed to send OTP: $e');
      return false;
    }
  }

  // Verify OTP and sign in
  Future<User?> verifyOTP({
    required String otp,
    required Function(String) onError,
  }) async {
    try {
      if (_verificationId == null) {
        onError('Verification ID not found. Please request OTP again.');
        return null;
      }

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      return await _signInWithCredential(credential);
    } catch (e) {
      onError('Invalid OTP: $e');
      return null;
    }
  }

  // Sign in with credential
  Future<User?> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      throw Exception('Sign-in failed: $e');
    }
  }

  // Resend OTP
  Future<bool> resendOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    return await sendOTP(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onError: onError,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if user is signed in
  bool isUserSignedIn() {
    return _auth.currentUser != null;
  }
}
