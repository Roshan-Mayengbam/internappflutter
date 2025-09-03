import 'package:flutter/material.dart';

class JobCardConstants {
  // Card styling
  static const double borderRadius = 20;
  static const EdgeInsets margin = EdgeInsets.all(16);
  static const EdgeInsets padding = EdgeInsets.all(16);

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
  static const TextStyle jobTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  // Banner text style
  static const TextStyle bannerTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: 1.2,
  );

  // Company name style
  static final TextStyle companyNameStyle = TextStyle(
    fontSize: 16,
    color: Colors.grey.shade700,
    fontFamily: "Nunito",
  );

  // Tag styling (delegates to FilterTag constants ideally)
  static const double tagFontSize = 13;
  static const FontWeight tagFontWeight = FontWeight.w600;
  static const double tagRadius = 20;

  static const List<BoxShadow> tagShadow = [
    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
  ];
}
