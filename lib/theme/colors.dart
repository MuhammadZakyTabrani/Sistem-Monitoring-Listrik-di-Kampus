import 'package:flutter/material.dart';

/// A centralized class for managing application colors and gradients.
class AppColors {
  // Primary Colors
  static const Color bluePrimary = Color(0xFF61B9F6); // Main primary color
  static const Color blueDark = Color(0xFF4A90E2); // Dark variant of primary color
  static const Color blueLight = Color(0xFF88D0F9); // Light variant of primary color

  // Background Colors
  static const Color lightBackground = Color(0xFFF8FAFB); // Light background color
  static const Color cardBackground = Color(0xFFFFFFFF); // Card background color

  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Success status color
  static const Color warning = Color(0xFFFF9800); // Warning status color
  static const Color error = Color(0xFFF44336); // Error status color
  static const Color info = Color(0xFF2196F3); // Info status color

  // Gradient Colors
  static const Color lightestBlue = Color(0xFFF0F8FF); // Lightest blue shade
  static const Color lightBlue = Color(0xFFD6EFFF); // Light blue shade
  static const Color mediumLightBlue = Color(0xFFB8DDFF); // Medium light blue shade
  static const Color mediumBlue = Color(0xFF87CEEB); // Medium blue shade
  static const Color mediumDarkBlue = Color(0xFF5DADE2); // Medium dark blue shade
  static const Color darkestBlue = Color(0xFF3498DB); // Darkest blue shade

  // Text Colors
  static const Color textPrimary = Color(0xFF212121); // Primary text color
  static const Color textSecondary = Color(0xFF757575); // Secondary text color
  static const Color textLight = Color(0xFF9E9E9E); // Light text color

  // Utility Colors
  static const Color divider = Color(0xFFE0E0E0); // Divider color
  static const Color shadow = Color(0x1A000000); // Shadow color with transparency

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [lightestBlue, darkestBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [lightBlue, mediumBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
