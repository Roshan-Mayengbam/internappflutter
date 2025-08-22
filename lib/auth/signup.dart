import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internappflutter/auth/otp_page.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row with Logo + Signup
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            "assets/svg/logo.svg",
                            height: 18,
                            width: 18,
                          ),
                          const SizedBox(width: 8),
                          SvgPicture.asset(
                            "assets/svg/logo_text.svg",
                            height: 18,
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF010101),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        onPressed: () {},
                        child: Text(
                          "Sign up",
                          style: GoogleFonts.jost(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Highlighted Text
                Container(
                  color: Colors.transparent, // optional background
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        color: Colors.yellow,
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          "JOIN AND START",
                          style: GoogleFonts.jost(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                      ),
                      Text(
                        "MATCHING WITH\nJOBS TODAY",
                        style: GoogleFonts.jost(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    ], // ✅ this closes children: []
                  ),
                ),

                SizedBox(height: 15),
                // Phone Number Input
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Phone Number",
                      style: GoogleFonts.jost(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          hintText: "+91 95674 43452",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontFamily: GoogleFonts.jost().fontFamily,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Get OTP Button
                SizedBox(
                  width: double.infinity,
                  height: 54.0,
                  child: Stack(
                    children: [
                      // Bottom layer (3D effect)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 0, // thickness of the 3D effect
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(
                              255,
                              0,
                              0,
                              0,
                            ), // darker shade for depth
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      // Top button
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(
                                  milliseconds: 400,
                                ),
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        OtpPage(),
                                transitionsBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      const begin = Offset(
                                        1.0,
                                        0.0,
                                      ); // Slide from right
                                      const end =
                                          Offset.zero; // End at normal position
                                      var tween = Tween(begin: begin, end: end)
                                          .chain(
                                            CurveTween(curve: Curves.easeInOut),
                                          );

                                      return SlideTransition(
                                        position: animation.drive(tween),
                                        child: child,
                                      );
                                    },
                              ),
                            );
                          },

                          child: const Text(
                            "Get OTP",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 5),

                // Divider with OR
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("OR"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 5),

                // Continue with Google
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          offset: const Offset(0, 4), // shadow only at bottom
                          blurRadius: 6,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
                        ),
                      ),
                      onPressed: () {},
                      icon: SvgPicture.asset(
                        "assets/svg/google_logo.svg",
                        height: 24,
                        width: 24,
                      ),
                      label: Text(
                        "Continue with Google",
                        style: GoogleFonts.jost(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                Align(
                  alignment:
                      Alignment.centerRight, // or .topRight, .bottomRight
                  child: Image.asset(
                    "assets/images/Cartoon_Network_Bear_Sticker.png",
                    fit: BoxFit.fitHeight,
                  ),
                ),
                Image.asset(
                  "assets/images/group_bottom.png",
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
