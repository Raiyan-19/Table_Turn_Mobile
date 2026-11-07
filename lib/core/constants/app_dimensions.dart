import 'package:flutter/material.dart';

/// Centralized UI dimensions, radii, padding, and layout constraints.
class AppDimensions {
  AppDimensions._();

  // Spacing / Margins / Padding
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // Screen Padding
  static const double screenHorizontalPadding = 20.0;
  static const double screenVerticalPadding = 16.0;

  // Border Radii
  static const double radiusXs = 6.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 10.0;
  static const double radiusLg = 14.0;
  static const double radiusXl = 16.0;
  static const double radiusXxl = 20.0;
  static const double radiusRound = 999.0;

  // Component Heights
  static const double buttonHeight = 54.0;
  static const double buttonHeightSm = 44.0;
  static const double inputHeight = 56.0;
  static const double searchBarHeight = 50.0;
  static const double cardHeight = 220.0;
  static const double appBarHeight = 60.0;

  // Max Width for Responsive Constraint
  static const double maxContentWidth = 500.0;

  // Common Insets
  static const EdgeInsets edgeInsetsScreen = EdgeInsets.symmetric(
    horizontal: screenHorizontalPadding,
    vertical: screenVerticalPadding,
  );
  static const EdgeInsets edgeInsetsCard = EdgeInsets.all(lg);
}

