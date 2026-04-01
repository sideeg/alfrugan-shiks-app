// Path: lib/core/utils/validators.dart
class Validators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الاسم مطلوب';
    }
    if (value.trim().length < 2) {
      return 'الاسم يجب أن يكون أكثر من حرفين';
    }
    if (value.trim().length > 255) {
      return 'الاسم طويل جداً';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'البريد الإلكتروني غير صالح';
    }

    if (value.trim().length > 255) {
      return 'البريد الإلكتروني طويل جداً';
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional
    }

    final phoneRegex = RegExp(r'^[+]?[0-9\s\-()]{10,20}$');

    if (!phoneRegex.hasMatch(value.trim())) {
      return 'رقم الهاتف غير صالح';
    }

    if (value.trim().length > 20) {
      return 'رقم الهاتف طويل جداً';
    }

    return null;
  }

  static String? validateNationalId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // National ID is optional
    }

    final nationalIdRegex = RegExp(r'^[0-9]{10,20}$');

    if (!nationalIdRegex.hasMatch(value.trim())) {
      return 'رقم الهوية يجب أن يكون أرقام فقط';
    }

    if (value.trim().length < 10) {
      return 'رقم الهوية قصير جداً';
    }

    if (value.trim().length > 20) {
      return 'رقم الهوية طويل جداً';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }

    if (value.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على حرف صغير';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على رقم';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على رمز خاص';
    }

    return null;
  }

  static String? validateQiraat(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Qiraat is optional
    }

    if (value.trim().length > 50) {
      return 'نص القراءة طويل جداً';
    }

    return null;
  }
}
