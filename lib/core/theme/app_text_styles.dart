import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';

class AppTextStyles {
  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontFamily: AppFonts.primary,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontFamily: AppFonts.primary,
    fontWeight: FontWeight.bold,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontFamily: AppFonts.primary,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontFamily: AppFonts.primary,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // Body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontFamily: AppFonts.primary,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontFamily: AppFonts.primary,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontFamily: AppFonts.primary,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  // Labels
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontFamily: AppFonts.primary,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontFamily: AppFonts.primary,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  // Button text
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontFamily: AppFonts.primary,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.textWhite,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontFamily: AppFonts.primary,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.textWhite,
  );

  // Caption
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontFamily: AppFonts.primary,
    fontWeight: FontWeight.normal,
    height: 1.3,
    color: AppColors.textTertiary,
  );
}
