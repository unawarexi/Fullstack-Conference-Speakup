/// Email validation
String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) return 'Email is required';
  final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  if (!regex.hasMatch(value.trim())) return 'Enter a valid email';
  return null;
}

/// Password validation (min 8 chars, 1 uppercase, 1 digit)
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Password is required';
  if (value.length < 8) return 'Minimum 8 characters';
  if (!value.contains(RegExp(r'[A-Z]'))) return 'At least one uppercase letter';
  if (!value.contains(RegExp(r'[0-9]'))) return 'At least one number';
  return null;
}

/// Confirm password
String? validateConfirmPassword(String? value, String password) {
  if (value != password) return 'Passwords do not match';
  return null;
}

/// Name
String? validateName(String? value) {
  if (value == null || value.trim().isEmpty) return 'Name is required';
  if (value.trim().length < 2) return 'Minimum 2 characters';
  return null;
}

/// Meeting ID (alphanumeric + hyphens, 3-20 chars)
String? validateMeetingId(String? value) {
  if (value == null || value.trim().isEmpty) return 'Meeting ID is required';
  final regex = RegExp(r'^[a-zA-Z0-9\-]{3,20}$');
  if (!regex.hasMatch(value.trim())) return 'Invalid meeting ID format';
  return null;
}

/// Generic required field
String? validateRequired(String? value, [String fieldName = 'This field']) {
  if (value == null || value.trim().isEmpty) return '$fieldName is required';
  return null;
}
