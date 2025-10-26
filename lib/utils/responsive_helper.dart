import 'package:flutter/material.dart';

/// Responsive layout helper to prevent overflow issues
class ResponsiveHelper {
  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      return const EdgeInsets.all(16.0);
    } else if (screenWidth < 900) {
      return const EdgeInsets.all(20.0);
    } else {
      return const EdgeInsets.all(24.0);
    }
  }

  /// Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // Adjust font size based on screen width
    double responsiveFontSize = baseFontSize;
    if (screenWidth < 600) {
      responsiveFontSize = baseFontSize * 0.9;
    } else if (screenWidth > 1200) {
      responsiveFontSize = baseFontSize * 1.1;
    }

    // Apply text scale factor
    return responsiveFontSize * textScaleFactor;
  }

  /// Get responsive grid cross axis count
  static int getResponsiveGridCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      return 1;
    } else if (screenWidth < 900) {
      return 2;
    } else if (screenWidth < 1200) {
      return 3;
    } else {
      return 4;
    }
  }

  /// Check if screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  /// Check if screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }

  /// Check if screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  /// Get responsive image aspect ratio
  static double getImageAspectRatio(BuildContext context) {
    if (isMobile(context)) {
      return 16 / 9; // Mobile: wider aspect ratio
    } else if (isTablet(context)) {
      return 4 / 3; // Tablet: square-ish
    } else {
      return 3 / 2; // Desktop: more square
    }
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return EdgeInsets.only(
      top: MediaQuery.of(context).padding.top,
      bottom: MediaQuery.of(context).padding.bottom,
      left: MediaQuery.of(context).padding.left,
      right: MediaQuery.of(context).padding.right,
    );
  }

  /// Create responsive container with proper constraints
  static Widget responsiveContainer({
    required Widget child,
    double? maxWidth,
    EdgeInsets? padding,
    BoxDecoration? decoration,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final effectiveMaxWidth = maxWidth ?? screenWidth;

        return Container(
          constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
          padding: padding ?? getResponsivePadding(context),
          decoration: decoration,
          child: child,
        );
      },
    );
  }
}
