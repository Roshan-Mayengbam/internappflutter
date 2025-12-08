import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.scaffold,
    fontFamily: 'Jost',
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      background: AppColors.scaffold,
    ),
    textTheme: const TextTheme(bodyMedium: AppTypography.bodySm),
    useMaterial3: false,
  );
}
