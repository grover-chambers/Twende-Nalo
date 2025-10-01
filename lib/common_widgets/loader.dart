import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final double size;
  final Color color;
  final String? message;
  final bool showBackground;
  final double backgroundOpacity;

  const Loader({
    super.key,
    this.size = 40.0,
    this.color = Colors.green,
    this.message,
    this.showBackground = false,
    this.backgroundOpacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (showBackground) {
      return Container(
        color: Color.fromRGBO(0, 0, 0, backgroundOpacity),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLoader(),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLoader(),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoader() {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: size * 0.1,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

// Shimmer loading effect for skeleton screens
class ShimmerLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }
}

// Full screen loader with logo
class FullScreenLoader extends StatelessWidget {
  final String? message;
  final bool showLogo;

  const FullScreenLoader({
    super.key,
    this.message,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showLogo) ...[
              Image.asset(
                'assets/images/logo.png',
                width: 120,
                height: 120,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.shopping_bag,
                  size: 80,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 32),
            ],
            const Loader(size: 50),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Small inline loader for buttons and small spaces
class InlineLoader extends StatelessWidget {
  final double size;
  final Color color;

  const InlineLoader({
    super.key,
    this.size = 16,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
