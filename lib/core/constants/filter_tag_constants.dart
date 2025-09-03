import 'package:flutter/material.dart';

class FilterTagConstants {
  // Shape
  static const double borderRadius = 8;
  static const EdgeInsets padding = EdgeInsets.symmetric(
    horizontal: 18,
    vertical: 12,
  );

  // Font
  static const double fontSize = 16;
  static const FontWeight fontWeight = FontWeight.w700;
  static const String fontFamily = "Poppins";

  // Selected State
  static const LinearGradient selectedGradient = LinearGradient(
    colors: [Colors.blue, Colors.teal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const List<BoxShadow> selectedShadow = [
    BoxShadow(color: Colors.blueAccent, blurRadius: 8, offset: Offset(0, 4)),
  ];

  // Unselected State
  static final Color unselectedBg = Colors.blue.shade50;
  static final Color unselectedText = Colors.blue.shade800;
  static final Border unselectedBorder = Border.all(
    color: Colors.blueAccent.shade100,
    width: 1.2,
  );
  static const List<BoxShadow> unselectedShadow = [
    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
  ];
}
