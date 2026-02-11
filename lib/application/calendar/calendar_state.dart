import 'package:equatable/equatable.dart';
import 'calendar_event.dart';

/// حالات BLoC التقويم
class CalendarState extends Equatable {
  final DateTime focusedDate;
  final DateTime selectedDate;
  final CalendarViewType viewType;
  final List<DateTime> visibleDays;

  const CalendarState({
    required this.focusedDate,
    required this.selectedDate,
    required this.viewType,
    required this.visibleDays,
  });

  /// الحالة الابتدائية
  factory CalendarState.initial() {
    final now = DateTime.now();
    return CalendarState(
      focusedDate: now,
      selectedDate: now,
      viewType: CalendarViewType.monthly,
      visibleDays: generateMonthDays(now),
    );
  }

  CalendarState copyWith({
    DateTime? focusedDate,
    DateTime? selectedDate,
    CalendarViewType? viewType,
    List<DateTime>? visibleDays,
  }) {
    return CalendarState(
      focusedDate: focusedDate ?? this.focusedDate,
      selectedDate: selectedDate ?? this.selectedDate,
      viewType: viewType ?? this.viewType,
      visibleDays: visibleDays ?? this.visibleDays,
    );
  }

  /// توليد أيام الشهر (بما في ذلك أيام الأسبوع الفارغة في البداية والنهاية)
  static List<DateTime> generateMonthDays(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final lastDay = DateTime(date.year, date.month + 1, 0);

    // يوم بداية الأسبوع (0 = الاثنين في هذا التقويم)
    int startWeekday = firstDay.weekday - 1; // Monday = 0

    final days = <DateTime>[];

    // أيام الشهر السابق
    for (int i = startWeekday - 1; i >= 0; i--) {
      days.add(firstDay.subtract(Duration(days: i + 1)));
    }

    // أيام الشهر الحالي
    for (int i = 0; i < lastDay.day; i++) {
      days.add(DateTime(date.year, date.month, i + 1));
    }

    // أيام الشهر التالي (لإكمال الشبكة إلى 42 يوم = 6 صفوف)
    final remaining = 42 - days.length;
    for (int i = 1; i <= remaining; i++) {
      days.add(DateTime(lastDay.year, lastDay.month, lastDay.day + i));
    }

    return days;
  }

  /// توليد أيام الأسبوع
  static List<DateTime> generateWeekDays(DateTime date) {
    // الاثنين هو أول يوم في الأسبوع
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  /// توليد ساعات اليوم
  static List<DateTime> generateDayHours(DateTime date) {
    return List.generate(
      24,
      (i) => DateTime(date.year, date.month, date.day, i),
    );
  }

  @override
  List<Object?> get props => [focusedDate, selectedDate, viewType, visibleDays];
}
