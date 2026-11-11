import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFF3B82F6);

  // Secondary colors
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryDark = Color(0xFF059669);

  // Status colors
  static const Color statusPending = Color(0xFFFBBF24); 
  static const Color statusActive = Color(0xFF3B82F6); 
  static const Color statusCompleted = Color(0xFF10B981); 
  static const Color statusCancelled = Color(0xFFEF4444); 
  static const Color statusInTransit = Color(0xFF8B5CF6); 

  // Neutral colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Background colors
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceHover = Color(0xFFF3F4F6);

  // Border colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);

  // Error/Warning/Success
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFFBBF24);
  static const Color success = Color(0xFF10B981);
  static const Color info = Color(0xFF3B82F6);

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}
