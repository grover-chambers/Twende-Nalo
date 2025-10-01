import 'package:flutter/material.dart';
import '../constants/layout/responsive_values.dart';

class ResponsiveWrapper extends StatelessWidget {
  const ResponsiveWrapper({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ResponsiveValues.responsiveValue(
      context,
      mobile: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: ResponsiveValues.mobilePadding),
        child: child,
      ),
      tablet: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: ResponsiveValues.tabletPadding),
        child: child,
      ),
      desktop: () => Center(
        child: SizedBox(
          width: ResponsiveValues.maxContentWidth(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: ResponsiveValues.desktopPadding),
            child: child,
          ),
        ),
      ),
      orElse: () => Center(
        child: SizedBox(
          width: ResponsiveValues.maxContentWidth(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: ResponsiveValues.desktopPadding),
            child: child,
          ),
        ),
      ),
    );
  }
}
