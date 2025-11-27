import 'package:flutter/material.dart';

class TagStyles {
  static const Color statusPillBg = Color(0xFFF9F3C6);
  static const Color statusPillBorder = Color(0xFF2C2C2C);
  static const Color statusPillFontColor = Color(0xFF343434);
  static const double statusPillFontSize = 16.0;

  static const Color actionChipBg = Colors.white; // 0xFFFFFFFF
  static const Color actionChipShadowColor = Color(0xFF000000);
  static const Color actionChipFontColor = Color(0xFF1FA7E3);
  static const double actionChipFontSize = 15.0;

  static const double borderRadius = 50.0;
  static const EdgeInsets padding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 8,
  );

  static const String fontFamily = 'Jost';
}

/// Defines the primary visual style and intent of the tag.
enum TagStyle {
  /// Used for static information, often highlighted (e.g., 'Online', 'Full Time').
  statusPill,

  /// Used for selectable items, skills, or generic listing attributes (e.g., 'ADOBE', 'Certificate').
  actionChip,
}
