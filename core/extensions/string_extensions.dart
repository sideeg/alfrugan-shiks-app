// Path: lib/core/extensions/string_extensions.dart
extension StringExtensions on String {
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
  
  bool get isValidPhone {
    return RegExp(r'^[0-9]{10,15}$').hasMatch(this);
  }
  
  String get capitalizeFirst {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
  
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
  
  bool get isArabic {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(this);
  }
}

