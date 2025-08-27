import 'package:flutter/material.dart';

/// UI-related constants and theme configuration
class UIConstants {

  // Spacing
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  // Border radius
  static const double defaultBorderRadius = 8.0;
  static const double largeBorderRadius = 12.0;

  // Image dimensions
  static const double listItemImageSize = 60.0;
  static const double formImageHeight = 200.0;

  // Icon sizes
  static const double smallIcon = 16.0;
  static const double defaultIcon = 24.0;
  static const double largeIcon = 48.0;
  static const double extraLargeIcon = 64.0;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration defaultAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Colors
  static const Color successColor = Colors.green;
  static const Color errorColor = Colors.red;
  static const Color warningColor = Colors.orange;
  static const Color infoColor = Colors.blue;

  // Common EdgeInsets
  static const EdgeInsets allPadding = EdgeInsets.all(defaultPadding);
  static const EdgeInsets horizontalPadding = EdgeInsets.symmetric(horizontal: defaultPadding);
  static const EdgeInsets verticalPadding = EdgeInsets.symmetric(vertical: defaultPadding);
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: defaultPadding,
    vertical: 4,
  );

  // Common BorderRadius
  static const BorderRadius defaultRadius = BorderRadius.all(
    Radius.circular(defaultBorderRadius),
  );
  static const BorderRadius largeRadius = BorderRadius.all(
    Radius.circular(largeBorderRadius),
  );
}