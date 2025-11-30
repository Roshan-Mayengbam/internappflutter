import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const primary = Color(0xFFAA8DFF); // purple-ish accent
  static const primarySurface = Color(0xFFF2EFFF);
  static const accentLime = Color(0xFFD9FF60);

  // Neutrals
  static const scaffold = Color(0xFFF7F7F7);
  static const card = Colors.white;
  static const borderStrong = Color(0xFF111111);
  static const borderSoft = Color(0xFFE1E1E1);

  // Text
  static const textPrimary = Color(0xFF111111);
  static const textSecondary = Color(0xFF6F6F6F);

  // Shadows
  static const shadowSoft = Color(0x14000000); // 8% black
  static const shadowSharp = Colors.black; //  black

  static final bannerGradient = const LinearGradient(
    colors: [Colors.purple, Colors.pinkAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
