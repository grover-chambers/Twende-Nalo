import 'package:flutter/material.dart';

class ResponsiveValues {
  // Breakpoints for responsive design
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Padding values
  static const double mobilePadding = 16.0;
  static const double tabletPadding = 24.0;
  static const double desktopPadding = 32.0;

  // Margin values
  static const double mobileMargin = 8.0;
  static const double tabletMargin = 16.0;
  static const double desktopMargin = 24.0;

  // Responsive value selector based on screen width
  static T responsiveValue<T>(
    BuildContext context, {
    required T Function() mobile,
    T Function()? tablet,
    T Function()? desktop,
    required T Function() orElse,
  }) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobileBreakpoint) {
      return mobile();
    } else if (width < tabletBreakpoint) {
      return tablet?.call() ?? orElse();
    } else if (width < desktopBreakpoint) {
      return tablet?.call() ?? orElse();
    } else {
      return desktop?.call() ?? orElse();
    }
  }

  // Card dimensions
  static double cardWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return width - (mobilePadding * 2);
    } else if (width < tabletBreakpoint) {
      return (width - (tabletPadding * 3)) / 2;
    } else {
      return (width - (desktopPadding * 4)) / 3;
    }
  }

  // Grid cross axis count
  static int gridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return 1;
    if (width < tabletBreakpoint) return 2;
    return 3;
  }

  // Responsive font sizes
  static double headlineSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return 24.0;
    if (width < tabletBreakpoint) return 28.0;
    return 32.0;
  }

  static double titleSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return 20.0;
    if (width < tabletBreakpoint) return 22.0;
    return 24.0;
  }

  static double bodySize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return 14.0;
    if (width < tabletBreakpoint) return 15.0;
    return 16.0;
  }

  // Responsive spacing
  static double smallSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return 8.0;
    if (width < tabletBreakpoint) return 12.0;
    return 16.0;
  }

  static double mediumSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return 16.0;
    if (width < tabletBreakpoint) return 20.0;
    return 24.0;
  }

  static double largeSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return 24.0;
    if (width < tabletBreakpoint) return 32.0;
    return 40.0;
  }

  // Button dimensions
  static double buttonHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return 48.0;
    if (width < tabletBreakpoint) return 52.0;
    return 56.0;
  }

  static double buttonMinWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return 120.0;
    if (width < tabletBreakpoint) return 140.0;
    return 160.0;
  }

  // App bar height
  static double appBarHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return 56.0;
    if (width < tabletBreakpoint) return 64.0;
    return 72.0;
  }

  // Bottom navigation height
  static double bottomNavHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return 56.0;
    if (width < tabletBreakpoint) return 64.0;
    return 72.0;
  }

  // Dialog width
  static double dialogWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return width - (mobilePadding * 2);
    if (width < tabletBreakpoint) return width * 0.7;
    return width * 0.5;
  }

  // Max content width
  static double maxContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return width;
    if (width < tabletBreakpoint) return width * 0.9;
    return 1200.0;
  }

  // Responsive icon sizes
  static double iconSizeSmall(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return 16.0;
    if (width < tabletBreakpoint) return 18.0;
    return 20.0;
  }

  static double iconSizeMedium(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return 24.0;
    if (width < tabletBreakpoint) return 28.0;
    return 32.0;
  }

  static double iconSizeLarge(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return 32.0;
    if (width < tabletBreakpoint) return 40.0;
    return 48.0;
  }
}
