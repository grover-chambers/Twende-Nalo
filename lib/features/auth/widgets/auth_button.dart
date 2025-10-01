import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final FontWeight? fontWeight;
  final BorderRadius? borderRadius;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool showShadow;
  final Color? loadingIndicatorColor;
  final Color? disabledBackgroundColor;
  final Color? disabledTextColor;

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.padding,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.borderRadius,
    this.prefixIcon,
    this.suffixIcon,
    this.showShadow = true,
    this.loadingIndicatorColor,
    this.disabledBackgroundColor,
    this.disabledTextColor,
  });

  factory AuthButton.primary({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isEnabled = true,
    Key? key,
  }) {
    return AuthButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isEnabled: isEnabled,
      backgroundColor: const Color(0xFF2563EB),
      textColor: Colors.white,
      fontWeight: FontWeight.w600,
      fontSize: 16,
      height: 56,
      borderRadius: BorderRadius.circular(12),
      showShadow: true,
    );
  }

  factory AuthButton.secondary({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isEnabled = true,
    Key? key,
  }) {
    return AuthButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isEnabled: isEnabled,
      backgroundColor: Colors.white,
      textColor: const Color(0xFF2563EB),
      fontWeight: FontWeight.w600,
      fontSize: 16,
      height: 56,
      borderRadius: BorderRadius.circular(12),
      showShadow: true,
    );
  }

  factory AuthButton.social({
    required String text,
    required VoidCallback onPressed,
    required Widget icon,
    bool isLoading = false,
    bool isEnabled = true,
    Color? backgroundColor,
    Color? textColor,
    Key? key,
  }) {
    return AuthButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isEnabled: isEnabled,
      backgroundColor: backgroundColor ?? Colors.white,
      textColor: textColor ?? Colors.black87,
      fontWeight: FontWeight.w500,
      fontSize: 16,
      height: 48,
      borderRadius: BorderRadius.circular(8),
      showShadow: true,
      prefixIcon: icon,
    );
  }

  factory AuthButton.textButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isEnabled = true,
    Key? key,
  }) {
    return AuthButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isEnabled: isEnabled,
      backgroundColor: Colors.transparent,
      textColor: const Color(0xFF2563EB),
      fontWeight: FontWeight.w500,
      fontSize: 14,
      height: 36,
      showShadow: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final effectiveBackgroundColor = isEnabled
        ? (backgroundColor ?? theme.primaryColor)
        : (disabledBackgroundColor ?? theme.disabledColor);
    
    final effectiveTextColor = isEnabled
        ? (textColor ?? Colors.white)
        : (disabledTextColor ?? Colors.white70);

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading || !isEnabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          foregroundColor: effectiveTextColor,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(12),
          ),
          elevation: showShadow ? 2 : 0,
          shadowColor: showShadow ? Colors.black.withOpacity(0.1) : null,
          disabledBackgroundColor: disabledBackgroundColor ?? theme.disabledColor,
          disabledForegroundColor: disabledTextColor ?? Colors.white70,
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    loadingIndicatorColor ?? effectiveTextColor,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (prefixIcon != null) ...[
                    prefixIcon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      color: effectiveTextColor,
                    ),
                  ),
                  if (suffixIcon != null) ...[
                    const SizedBox(width: 8),
                    suffixIcon!,
                  ],
                ],
              ),
      ),
    );
  }
}

// Usage example widget
class AuthButtonExamples extends StatelessWidget {
  const AuthButtonExamples({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        AuthButton.primary(
          text: 'Sign In',
          onPressed: () {},
        ),
        const SizedBox(height: 16),
        AuthButton.secondary(
          text: 'Create Account',
          onPressed: () {},
        ),
        const SizedBox(height: 16),
        AuthButton.social(
          text: 'Continue with Google',
          onPressed: () {},
          icon: const Icon(Icons.g_mobiledata, size: 24),
        ),
        const SizedBox(height: 16),
        AuthButton.textButton(
          text: 'Forgot Password?',
          onPressed: () {},
        ),
      ],
    );
  }
}
