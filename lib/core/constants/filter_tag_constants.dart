import 'package:flutter/material.dart';

class FilterTagConstants {
  // Shape
  static final BorderRadius borderRadius = BorderRadius.circular(8);
  static final Border border = Border.all(color: Colors.black, width: 1.2);
  static const EdgeInsets padding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 12,
  );

  // TextStyle
  static const double fontSize = 14;
  static const FontWeight fontWeight = FontWeight.w500;
  static const String fontFamily = "Jost";
  static const Color textColor = Colors.black;
  static const TextStyle filterText = TextStyle(
    fontWeight: fontWeight,
    fontSize: fontSize,
    fontFamily: fontFamily,
    color: textColor,
  );

  // Selected State
  static Color selectedBg = Color(0xFFE2FDAB);

  // Unselected State
  static final Color unselectedBg = Colors.white;
}
