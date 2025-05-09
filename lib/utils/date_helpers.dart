import 'package:intl/intl.dart';

class DateHelpers {
  static String formatDate(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  static String getCurrentMonthYear() {
    final now = DateTime.now();
    return DateFormat('yyyy-MM').format(now);
  }
  static List<String> getRecentMonthYears(int count) {
    final now = DateTime.now();
    return List.generate(count, (index) {
      final date = DateTime(now.year, now.month - index, 1);
      final fixedDate = DateTime(date.year, date.month, 1);
      return DateFormat('yyyy-MM').format(fixedDate); 
    });
  }
}
