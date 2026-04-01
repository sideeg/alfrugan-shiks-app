// Path: lib/core/utils/formatters.dart
import 'package:intl/intl.dart';

class Formatters {
  static String formatNumber(num number) {
    return NumberFormat('#,##0', 'ar').format(number);
  }
  
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }
  
  static String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'ar', symbol: 'ر.س').format(amount);
  }
  
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
  
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}

