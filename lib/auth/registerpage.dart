import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internappflutter/auth/collegedetails.dart';
import 'package:internappflutter/models/usermodel.dart';

class RegisterPage extends StatefulWidget {
  final UserModel? userModel;
  final File? profileImage;
  final GoogleSignInAccount? googleUser;
  const RegisterPage({
    Key? key,
    this.userModel,
    this.profileImage,
    this.googleUser,
  }) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;
  String selectedCountryCode = '+91';

  @override
  void initState() {
    super.initState();
    // ✅ Pre-populate fields with Google user data
    if (widget.userModel != null) {
      fullNameController.text = widget.userModel!.name;
      emailController.text = widget.userModel!.email;

      // Handle phone number - remove country code if present
      if (widget.userModel!.phone != null &&
          widget.userModel!.phone!.isNotEmpty) {
        String phone = widget.userModel!.phone!;
        if (phone.startsWith('+91')) {
          phoneController.text = phone.substring(3);
        } else if (phone.startsWith('91')) {
          phoneController.text = phone.substring(2);
        } else {
          phoneController.text = phone;
        }
      }

      print("Pre-populated data:");
      print("Name: ${fullNameController.text}");
      print("Email: ${emailController.text}");
      print("Phone: ${phoneController.text}");
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),

                // Top Logo
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "hyrup",
                    style: GoogleFonts.dancingScript(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ✅ Show profile picture if available
                const SizedBox(height: 20),

                // Character and Register Banner
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Character image
                    Container(
                      width: 120,
                      height: 150,
                      child: Image.asset(
                        'assets/images/Cartoon_Network_Bear_Sticker.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(width: 16),

                    // Register banner
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  'assets/Union.png',
                                  fit: BoxFit.contain,
                                ),
                                Text(
                                  'REGISTER',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontFamily: 'Jost',
                                    fontWeight: FontWeight.w900,
                                    color: const Color.fromARGB(
                                      255,
                                      17,
                                      12,
                                      12,
                                    ),
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Full Name Field (✅ Pre-populated)
                Text(
                  "Full Name",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: fullNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter your full name',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Phone Number Field (✅ Pre-populated)
                Text(
                  "Phone Number",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Country Code Selector
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 16,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Image.asset(
                                'assets/images/india_flag.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.orange,
                                    child: Icon(
                                      Icons.flag,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '+91',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 20, color: Colors.grey[300]),
                      Expanded(
                        child: TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'Enter phone number',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Email Field (✅ Pre-populated)
                Text(
                  "Email",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    readOnly: widget.userModel != null,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: widget.userModel != null
                          ? Colors.grey[50] // Different color for read-only
                          : Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      suffixIcon: widget.userModel != null
                          ? Icon(Icons.verified, color: Colors.green, size: 20)
                          : null,
                    ),
                  ),
                ),

                if (widget.userModel != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "Email verified with Google",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.green[600],
                      ),
                    ),
                  ),

                const SizedBox(height: 60),

                // Next Button
                Container(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (fullNameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Full Name is required")),
                        );
                        return;
                      }
                      if (phoneController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Phone Number is required")),
                        );
                        return;
                      }
                      if (emailController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Email is required")),
                        );
                        return;
                      }

                      // ✅ Create updated user model
                      final updatedUserModel = UserModel(
                        name: fullNameController.text.trim(),
                        email: emailController.text.trim(),
                        phone: phoneController.text.trim().isNotEmpty
                            ? '+91${phoneController.text.trim()}'
                            : null,
                        profileImageUrl: widget.userModel?.profileImageUrl,
                        uid: widget.userModel?.uid ?? '',
                        role: widget.userModel?.role ?? 'Student',
                      );

                      print(
                        "Updated user model: ${updatedUserModel.toString()}",
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Collegedetails(userModel: updatedUserModel),
                        ),
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
