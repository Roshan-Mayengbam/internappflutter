// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:internappflutter/auth/FirebaseOTPService.dart';
// import 'package:internappflutter/auth/registerpage.dart';

// class OtpPage extends StatefulWidget {
//   final String phoneNumber;
//   final FirebaseOTPService otpService;

//   const OtpPage({
//     super.key,
//     required this.phoneNumber,
//     required this.otpService,
//   });

//   @override
//   State<OtpPage> createState() => _OtpPageState();
// }

// class _OtpPageState extends State<OtpPage> {
//   final List<TextEditingController> _otpControllers = List.generate(
//     4,
//     (index) => TextEditingController(),
//   );
//   final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

//   bool _isLoading = false;
//   bool _isResending = false;
//   int _resendTimer = 60;
//   bool _canResend = false;

//   @override
//   void initState() {
//     super.initState();
//     _startResendTimer();
//   }

//   void _startResendTimer() {
//     _canResend = false;
//     _resendTimer = 60;

//     Future.doWhile(() async {
//       await Future.delayed(const Duration(seconds: 1));
//       if (mounted) {
//         setState(() {
//           _resendTimer--;
//           if (_resendTimer <= 0) {
//             _canResend = true;
//           }
//         });
//       }
//       return _resendTimer > 0 && mounted;
//     });
//   }

//   void _verifyOTP() async {
//     String otp = _otpControllers.map((controller) => controller.text).join();

//     if (otp.length != 4) {
//       _showSnackBar('Please enter complete OTP', Colors.red);
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       User? user = await widget.otpService.verifyOTP(
//         otp: otp,
//         onError: (error) {
//           setState(() {
//             _isLoading = false;
//           });
//           _showSnackBar(error, Colors.red);
//         },
//       );

//       setState(() {
//         _isLoading = false;
//       });

//       if (user != null) {
//         _showSnackBar('Phone number verified successfully!', Colors.green);

//         // Navigate to register page or next screen
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => RegisterPage(),
//             // RegisterPage(phoneNumber: widget.phoneNumber, user: user),
//           ),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       _showSnackBar('Verification failed: $e', Colors.red);
//     }
//   }

//   void _resendOTP() async {
//     if (!_canResend || _isResending) return;

//     setState(() {
//       _isResending = true;
//     });

//     await widget.otpService.resendOTP(
//       phoneNumber: widget.phoneNumber,
//       onCodeSent: (message) {
//         setState(() {
//           _isResending = false;
//         });
//         _showSnackBar('OTP resent successfully', Colors.green);
//         _startResendTimer();

//         // Clear existing OTP fields
//         for (var controller in _otpControllers) {
//           controller.clear();
//         }
//         _focusNodes[0].requestFocus();
//       },
//       onError: (error) {
//         setState(() {
//           _isResending = false;
//         });
//         _showSnackBar(error, Colors.red);
//       },
//     );
//   }

//   void _showSnackBar(String message, Color backgroundColor) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: backgroundColor,
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }

//   void _onOtpChanged(String value, int index) {
//     if (value.length == 1 && index < 3) {
//       _focusNodes[index + 1].requestFocus();
//     } else if (value.isEmpty && index > 0) {
//       _focusNodes[index - 1].requestFocus();
//     }

//     // Auto-verify if all fields are filled
//     String otp = _otpControllers.map((controller) => controller.text).join();
//     if (otp.length == 4 && !_isLoading) {
//       _verifyOTP();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Top Row: Logo + Sign Up Button
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         SvgPicture.asset(
//                           "assets/svg/logo.svg",
//                           height: 18,
//                           width: 18,
//                         ),
//                         const SizedBox(width: 8),
//                         SvgPicture.asset(
//                           "assets/svg/logo_text.svg",
//                           height: 18,
//                         ),
//                       ],
//                     ),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Color(0xFF010101),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                           vertical: 10,
//                         ),
//                       ),
//                       onPressed: () {},
//                       child: Text(
//                         "Sign up",
//                         style: GoogleFonts.jost(color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 40),

//                 // Title
//                 Container(
//                   color: Colors.transparent,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Container(
//                         color: Colors.yellow,
//                         padding: const EdgeInsets.all(4),
//                         child: Text(
//                           "ENTER THE",
//                           style: GoogleFonts.jost(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 30,
//                           ),
//                         ),
//                       ),
//                       Text(
//                         "VERIFICATION\nCODE",
//                         style: GoogleFonts.jost(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 30,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // Phone number display
//                 Center(
//                   child: Text(
//                     "Code sent to ${widget.phoneNumber}",
//                     style: GoogleFonts.jost(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//                 const SizedBox(height: 30),

//                 // OTP Label
//                 Text(
//                   "Enter 4-digit code",
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 12),

//                 // OTP Input Boxes
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: List.generate(
//                     4,
//                     (index) => Container(
//                       height: 55,
//                       width: 55,
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: _otpControllers[index].text.isNotEmpty
//                               ? Colors.black
//                               : Colors.grey.shade400,
//                           width: _otpControllers[index].text.isNotEmpty ? 2 : 1,
//                         ),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: TextField(
//                         controller: _otpControllers[index],
//                         focusNode: _focusNodes[index],
//                         textAlign: TextAlign.center,
//                         keyboardType: TextInputType.number,
//                         maxLength: 1,
//                         enabled: !_isLoading,
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         inputFormatters: [
//                           FilteringTextInputFormatter.digitsOnly,
//                         ],
//                         decoration: const InputDecoration(
//                           border: InputBorder.none,
//                           counterText: "",
//                         ),
//                         onChanged: (value) => _onOtpChanged(value, index),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // Resend OTP Text
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: _isResending
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : TextButton(
//                           onPressed: _canResend ? _resendOTP : null,
//                           child: Text(
//                             _canResend
//                                 ? "Resend OTP"
//                                 : "Resend in ${_resendTimer}s",
//                             style: TextStyle(
//                               color: _canResend ? Colors.blue : Colors.grey,
//                             ),
//                           ),
//                         ),
//                 ),
//                 const SizedBox(height: 20),

//                 // Verify OTP Button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => BottomnavbarAlternative(),
//                         ),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.black,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: _isLoading
//                         ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: Colors.white,
//                             ),
//                           )
//                         : const Text(
//                             "Verify OTP",
//                             style: TextStyle(color: Colors.white, fontSize: 16),
//                           ),
//                   ),
//                 ),

//                 const SizedBox(height: 12),

//                 // Back button
//                 Center(
//                   child: TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: Text(
//                       "Change phone number",
//                       style: GoogleFonts.jost(
//                         color: Colors.grey[600],
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // Bottom character + design
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: Image.asset(
//                     "assets/images/Cartoon_Network_Bear_Sticker.png",
//                     fit: BoxFit.fitHeight,
//                   ),
//                 ),
//                 Image.asset(
//                   "assets/images/Group_bottom.png",
//                   height: 100,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     for (var controller in _otpControllers) {
//       controller.dispose();
//     }
//     for (var focusNode in _focusNodes) {
//       focusNode.dispose();
//     }
//     super.dispose();
//   }
// }
