/// Input validation utilities
class InputValidator {
  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  /// Validate name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }

    final nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }

    return null;
  }

  /// Validate focus duration (1-180 minutes)
  static String? validateDuration(String? value) {
    if (value == null || value.isEmpty) {
      return 'Duration is required';
    }

    final duration = int.tryParse(value);
    if (duration == null) {
      return 'Please enter a valid number';
    }

    if (duration < 1) {
      return 'Duration must be at least 1 minute';
    }

    if (duration > 180) {
      return 'Duration cannot exceed 180 minutes';
    }

    return null;
  }

  /// Validate phone number (optional)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    final phoneRegex = RegExp(r'^\+?[1-9]\d{9,14}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''))) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Sanitize user input (remove dangerous characters)
  static String sanitize(String input) {
    return input.replaceAll(RegExp(r'[<>]'), '').trim();
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate number range
  static String? validateNumberRange(
    String? value,
    int min,
    int max,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    final number = int.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number < min || number > max) {
      return '$fieldName must be between $min and $max';
    }

    return null;
  }
}
