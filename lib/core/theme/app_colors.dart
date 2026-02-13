import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFD1A545);
  static const Color secondary = Color(0xFFDD5C04);

  static const Color primaryDark = Color(0xFFD1A545);

  // Background Colors
  static const Color background = Color(0xFF0F1115);
  static const Color backgroundLight = Color(0xFF0F1115);
  static const Color surface = Color(0xFF161A20);
  static const Color surfaceLight = Color(0xFF161A20);

  // Border Colors
  static const Color border = Color.fromARGB(0, 28, 28, 12);
  static const Color borderLight = Color(0xFF1E2A40);

  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF5D6F8F);
  static const Color textTertiary = Color(0xFF6B7280);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Accent Colors
  static const Color accent = Color(0xFF8B5CF6);
  static const Color accentLight = Color(0xFFA78BFA);

  // Opacity Helpers
  static Color withAlpha(Color color, double alpha) {
    return color.withValues(alpha: alpha);
  }

  static Color textPrimaryWithAlpha(double alpha) {
    return textPrimary.withValues(alpha: alpha);
  }

  static Color textSecondaryWithAlpha(double alpha) {
    return textSecondary.withValues(alpha: alpha);
  }

  static Color primaryWithAlpha(double alpha) {
    return primary.withValues(alpha: alpha);
  }
}
