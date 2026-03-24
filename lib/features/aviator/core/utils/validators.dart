class Validators {
  // Phone number validator
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Enter a valid 10 digit phone number';
    }
    return null;
  }

  // Password validator
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Confirm password validator
  static String? validateConfirmPassword(
    String? value,
    String? originalPassword,
  ) {
    if (value == null || value.isEmpty) {
      return 'Confirm your password';
    }
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Email validator
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  // Verification code
  static String? validateVericationCode(String? value, {int length = 6}) {
    if (value == null || value.trim().isEmpty) {
      return 'Verification code required';
    }
    final trimmed = value.trim();
    if (trimmed.length != length) {
      return 'Code must be $length digits';
    }
    if (!RegExp(r'^\d+$').hasMatch(trimmed)) {
      return 'Code must contain only digits';
    }
    return null;
  }

  // Full name validator
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name required';
    }
    final trimmed = value.trim();

    // Check at least 2 words
    if (trimmed.split(' ').length < 2) {
      return 'Enter your full name (first & last name)';
    }

    // Allow only letters and spaces
    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(trimmed)) {
      return 'Name can only contain letters and spaces';
    }

    return null;
  }
}
