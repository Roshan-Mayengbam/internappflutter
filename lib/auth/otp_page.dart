import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internappflutter/bottomnavbar.dart';
import 'package:internappflutter/home/home_page.dart';

class OtpPage extends StatelessWidget {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Logo + Sign Up Button
                Row(
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
                const SizedBox(height: 40),

                // Title
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
                const SizedBox(height: 40),

                // OTP Label
                Text(
                  "OTP",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // OTP Input Boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    4,
                    (index) => Container(
                      height: 55,
                      width: 55,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: "",
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Send OTP Text
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text("Send OTP"),
                  ),
                ),
                const SizedBox(height: 20),

                // Enter OTP Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BottomnavbarAlternative(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Enter OTP",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Bottom character + design
                Align(
                  alignment:
                      Alignment.centerRight, // or .topRight, .bottomRight
                  child: Image.asset(
                    "assets/images/Cartoon_Network_Bear_Sticker.png",
                    fit: BoxFit.fitHeight,
                  ),
                ),
                Image.asset(
                  "assets/images/Group_bottom.png",
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
