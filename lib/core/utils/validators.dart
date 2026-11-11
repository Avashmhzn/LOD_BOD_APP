class Validators {
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email) && email.length <= 254;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one digit';
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  static String sanitizeInput(String input) {
    return input
        .replaceAll(RegExp(r'[<>]'), '')
        .replaceAll(RegExp("[;\"']"), '')
        .trim();
  }

  static String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return 'Username is required';
    }
    if (username.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (username.length > 20) {
      return 'Username must be less than 20 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    return null;
  }
}
