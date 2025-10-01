import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A comprehensive text field widget for authentication forms
class AuthTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextStyle? style;
  final TextAlign textAlign;
  final bool readOnly;
  final VoidCallback? onTap;
  final Color? fillColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final bool showLabel;
  final bool showHint;

  const AuthTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.focusNode,
    this.autofocus = false,
    this.style,
    this.textAlign = TextAlign.start,
    this.readOnly = false,
    this.onTap,
    this.fillColor,
    this.borderColor,
    this.borderRadius = 12.0,
    this.contentPadding,
    this.showLabel = true,
    this.showHint = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      inputFormatters: inputFormatters,
      enabled: enabled,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      focusNode: focusNode,
      autofocus: autofocus,
      style: style ?? theme.textTheme.bodyLarge,
      textAlign: textAlign,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: showHint ? hintText : null,
        labelText: showLabel ? (labelText ?? hintText) : null,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fillColor ?? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: borderColor ?? theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: borderColor ?? theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 1.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 2.0,
          ),
        ),
        contentPadding: contentPadding ?? const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 16.0,
        ),
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        errorStyle: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
        counterStyle: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

/// Specialized email field
class AuthEmailField extends AuthTextField {
  const AuthEmailField({
    super.key,
    TextEditingController? controller,
    String? hintText = 'Enter your email',
    String? labelText = 'Email',
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
    TextInputAction? textInputAction = TextInputAction.next,
    FocusNode? focusNode,
  }) : super(
          controller: controller,
          hintText: hintText,
          labelText: labelText,
          keyboardType: TextInputType.emailAddress,
          textInputAction: textInputAction,
          onChanged: onChanged,
          validator: validator ?? _defaultEmailValidator,
          prefixIcon: const Icon(Icons.email_outlined),
          focusNode: focusNode,
        );

  static String? _defaultEmailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }
}

/// Specialized password field with visibility toggle
class AuthPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;

  const AuthPasswordField({
    super.key,
    this.controller,
    this.hintText = 'Enter your password',
    this.labelText = 'Password',
    this.onChanged,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
  });

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: widget.controller,
      hintText: widget.hintText,
      labelText: widget.labelText,
      obscureText: _obscureText,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      validator: widget.validator ?? _defaultPasswordValidator,
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
      focusNode: widget.focusNode,
    );
  }

  static String? _defaultPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}

/// Specialized name field
class AuthNameField extends AuthTextField {
  const AuthNameField({
    super.key,
    TextEditingController? controller,
    String? hintText = 'Enter your name',
    String? labelText = 'Full Name',
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
    TextInputAction? textInputAction = TextInputAction.next,
    FocusNode? focusNode,
  }) : super(
          controller: controller,
          hintText: hintText,
          labelText: labelText,
          keyboardType: TextInputType.name,
          textInputAction: textInputAction,
          onChanged: onChanged,
          validator: validator ?? _defaultNameValidator,
          prefixIcon: const Icon(Icons.person_outline),
          focusNode: focusNode,
        );

  static String? _defaultNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }
}

/// Specialized phone field
class AuthPhoneField extends AuthTextField {
  AuthPhoneField({
    super.key,
    TextEditingController? controller,
    String? hintText = 'Enter your phone number',
    String? labelText = 'Phone Number',
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
    TextInputAction? textInputAction = TextInputAction.next,
    FocusNode? focusNode,
  }) : super(
          controller: controller,
          hintText: hintText,
          labelText: labelText,
          keyboardType: TextInputType.phone,
          textInputAction: textInputAction,
          onChanged: onChanged,
          validator: validator ?? _defaultPhoneValidator,
          prefixIcon: const Icon(Icons.phone_outlined),
          inputFormatters: [
            FilteringTextInputFormatter(RegExp(r'[0-9]'), allow: true),
          ],
          focusNode: focusNode,
        );

  static String? _defaultPhoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (value.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }
}
