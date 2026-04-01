// Path: lib/l10n/app_localizations.dart
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Common
  String get appName => 'تطبيق الشيوخ';
  String get ok => 'موافق';
  String get cancel => 'إلغاء';
  String get save => 'حفظ';
  String get delete => 'حذف';
  String get edit => 'تعديل';
  String get add => 'إضافة';
  String get search => 'بحث';
  String get loading => 'جاري التحميل...';
  String get error => 'خطأ';
  String get success => 'نجح';
  String get retry => 'إعادة المحاولة';

  // Auth
  String get login => 'تسجيل الدخول';
  String get logout => 'تسجيل الخروج';
  String get email => 'البريد الإلكتروني';
  String get password => 'كلمة المرور';
  String get forgotPassword => 'نسيت كلمة المرور؟';
  String get loginWelcome => 'أهلاً بك في تطبيق الشيوخ';

  // Dashboard
  String get dashboard => 'الرئيسية';
  String get welcome => 'أهلاً وسهلاً';
  String get quickActions => 'الإجراءات السريعة';
  String get statistics => 'الإحصائيات';
  String get recentActivities => 'الأنشطة الأخيرة';

  // Courses
  String get courses => 'الدورات';
  String get courseDetails => 'تفاصيل الدورة';
  String get activeCourses => 'الدورات النشطة';
  String get totalStudents => 'إجمالي الطلاب';

  // Students
  String get students => 'الطلاب';
  String get studentDetails => 'تفاصيل الطالب';
  String get studentProgress => 'تقدم الطالب';

  // Logs
  String get logs => 'السجلات';
  String get addHifzLog => 'إضافة سجل حفظ';
  String get addReviewLog => 'إضافة مراجعة';
  String get dailyReports => 'التقارير اليومية';

  // Profile
  String get profile => 'الملف الشخصي';
  String get editProfile => 'تعديل الملف الشخصي';
  String get settings => 'الإعدادات';

  // Notifications
  String get notifications => 'الإشعارات';
  String get noNotifications => 'لا توجد إشعارات';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

