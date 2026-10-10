import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      fontFamily: 'Roboto',
      // Global text theme tuned to app's design system
      textTheme: const TextTheme(
        titleMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),
        titleSmall: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700),
        bodyMedium: TextStyle(fontSize: 14.0),
        bodySmall: TextStyle(fontSize: 13.0),
      ),
      // Use primary color for icons by default to align with the brand
      iconTheme: const IconThemeData(color: AppColors.primary, size: 16),
      // Subtle divider used between cards and list sections
      dividerTheme: DividerThemeData(color: Colors.grey.shade200, thickness: 1),
      // Card elevated look (kept default to maintain compatibility with SDK)
    );
  }
}
