import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 80,
    this.tooltip,
  });

  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final darkMode = FlutterLogo(
      size: size,
    );
    final lightMode = FlutterLogo(
      size: size,
    );

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Widget child = isDarkMode ? darkMode : lightMode;
    if (tooltip != null) {
      child = Tooltip(
        message: tooltip!,
        child: child,
      );
    }
    return child;
  }
}
