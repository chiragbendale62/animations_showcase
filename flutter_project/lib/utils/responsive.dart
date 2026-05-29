import 'package:flutter/material.dart';

/// Breakpoint helpers for adaptive layouts across phone, tablet, and desktop.
class Responsive {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  static Size sizeOf(BuildContext context) => MediaQuery.sizeOf(context);

  static bool isMobile(BuildContext context) =>
      sizeOf(context).width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = sizeOf(context).width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      sizeOf(context).width >= tabletBreakpoint;

  static double horizontalPadding(BuildContext context) {
    if (isDesktop(context)) return 48;
    if (isTablet(context)) return 32;
    return 16;
  }

  static int gridCrossAxisCount(BuildContext context) {
    if (isDesktop(context)) return 3;
    if (isTablet(context)) return 2;
    return 1;
  }

  static double gridChildAspectRatio(BuildContext context) {
    if (isTablet(context)) return 1.6;
    return 1.35;
  }

  static double titleFontSize(BuildContext context) {
    if (isMobile(context)) return 28;
    if (isTablet(context)) return 32;
    return 36;
  }

  static bool useVerticalComparisonLayout(BuildContext context) =>
      sizeOf(context).width < 700;

  static bool useCompactControls(BuildContext context) =>
      sizeOf(context).width < 400;
}
