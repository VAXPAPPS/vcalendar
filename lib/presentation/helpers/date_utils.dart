import 'package:intl/intl.dart';

/// دوال مساعدة للتواريخ
class CalendarDateUtils {
  /// هل هذا التاريخ هو اليوم؟
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// هل تاريخين في نفس اليوم؟
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// هل التاريخ ينتمي للشهر المحدد؟
  static bool isCurrentMonth(DateTime date, DateTime focusedDate) {
    return date.month == focusedDate.month && date.year == focusedDate.year;
  }

  /// تنسيق عنوان الشهر
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  /// تنسيق عنوان الأسبوع
  static String formatWeekRange(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    final startFormat = DateFormat('d MMM');
    final endFormat = DateFormat('d MMM yyyy');
    return '${startFormat.format(monday)} - ${endFormat.format(sunday)}';
  }

  /// تنسيق عنوان اليوم
  static String formatDayTitle(DateTime date) {
    return DateFormat('EEEE, d MMMM yyyy').format(date);
  }

  /// تنسيق الوقت
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// تنسيق التاريخ الكامل
  static String formatFullDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// أسماء أيام الأسبوع المختصرة
  static const List<String> weekDayNames = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  /// مفتاح التاريخ لتجميع الأحداث
  static String dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
