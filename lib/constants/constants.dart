import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Papela Event Rentals';
  static const double maxWidth = 1200.0;
  static const double cardElevation = 2.0;
  static const double borderRadius = 8.0;

  // Responsive breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
}

class AppColors {
  // Premium Palette
  static const Color primary = Color(0xFF1A237E); // Deep Navy
  static const Color primaryLight = Color(0xFF534BAE);
  static const Color primaryDark = Color(0xFF000051);

  static const Color secondary = Color(0xFFC5A059); // Gold/Champagne
  static const Color secondaryLight = Color(0xFFF8D186);
  static const Color secondaryDark = Color(0xFF94722E);

  static const Color background = Color(0xFFFAFAFA); // Off-white/Cream
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF2E7D32);

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
}
