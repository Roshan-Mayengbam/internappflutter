import 'package:flutter/material.dart';

class CarouselCardConstants {
  // Card styling
  static const double borderRadius = 20;
  static const EdgeInsets margin = EdgeInsets.symmetric(
    horizontal: 4,
    vertical: 12,
  );
  static const EdgeInsets padding = EdgeInsets.all(10);

  static final Border cardBorder = Border.all(
    color: Colors.grey.shade400,
    width: 1.5,
  );

  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  // Banner gradient
  static const LinearGradient bannerGradient = LinearGradient(
    colors: [Colors.purple, Colors.pinkAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Job title style
  static const double jobFontSize =
      18; // Reduced font size to help with overflow
  static const FontWeight jobFontWeight = FontWeight.w700;
  static const Color jobTextColor = Colors.black87;
  static const jobFontFamily = "jost";
  static const TextStyle jobTitleStyle = TextStyle(
    fontSize: jobFontSize,
    fontFamily: jobFontFamily,
    fontWeight: jobFontWeight,
    color: jobTextColor,
  );

  // Banner text style
  static const TextStyle bannerTextStyle = TextStyle(
    fontSize: 20, // Reduced font size to help with overflow
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: 1.2,
  );

  // Company name style
  static const double companyFontSize = 13;
  static const FontWeight companyFontWeight = FontWeight.w500;
  static Color companyTextColor = Colors.grey.shade700;
  static const companyFontFamily = "jost";
  static final TextStyle companyNameStyle = TextStyle(
    fontSize: companyFontSize,
    fontWeight: companyFontWeight,
    color: companyTextColor,
    fontFamily: companyFontFamily,
  );

  // Tag styling (delegates to FilterTag constants ideally)
  static const double tagFontSize = 11; // Reduced font size for tags
  static const FontWeight tagFontWeight = FontWeight.w600;
  static const double tagRadius = 20;

  static const List<BoxShadow> tagShadow = [
    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
  ];
}
