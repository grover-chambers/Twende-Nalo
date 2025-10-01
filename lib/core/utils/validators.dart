// lib/utils/validators.dart

class Validators {
  // Validate that the field is not empty
  static String? validateRequired(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Validate email format using regex
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Validate password strength (min 8 chars, at least one uppercase, one lowercase, one digit, one special char)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    final passwordRegExp = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    if (!passwordRegExp.hasMatch(value)) {
      return 'Password must be at least 8 characters, include uppercase, lowercase, number, and special character';
    }
    return null;
  }

  // Validate phone number (example pattern for Kenyan phone numbers)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegExp = RegExp(r'^\+?2547\d{8}$'); // Kenyan mobile numbers starting with +2547 or 07
    if (!phoneRegExp.hasMatch(value.trim())) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  // Validate name (only alphabets and spaces, min 2 characters)
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    final nameRegExp = RegExp(r"^[a-zA-Z ]{2,}$");
    if (!nameRegExp.hasMatch(value.trim())) {
      return 'Please enter a valid name (only letters and spaces)';
    }
    return null;
  }

  // Validate confirm password matches password
  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }
}
