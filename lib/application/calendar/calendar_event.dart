import 'package:equatable/equatable.dart';

/// عرض التقويم (شهري، أسبوعي، يومي)
enum CalendarViewType { monthly, weekly, daily }

/// أحداث BLoC التقويم
abstract class CalendarBlocEvent extends Equatable {
  const CalendarBlocEvent();

  @override
  List<Object?> get props => [];
}

/// الانتقال للشهر/الأسبوع/اليوم التالي
class NavigateNext extends CalendarBlocEvent {}

/// الانتقال للشهر/الأسبوع/اليوم السابق
class NavigatePrevious extends CalendarBlocEvent {}

/// الانتقال لتاريخ محدد
class NavigateToDate extends CalendarBlocEvent {
  final DateTime date;
  const NavigateToDate(this.date);

  @override
  List<Object?> get props => [date];
}

/// العودة لليوم الحالي
class NavigateToToday extends CalendarBlocEvent {}

/// تبديل نوع العرض
class ChangeViewType extends CalendarBlocEvent {
  final CalendarViewType viewType;
  const ChangeViewType(this.viewType);

  @override
  List<Object?> get props => [viewType];
}

/// اختيار يوم معين
class SelectDate extends CalendarBlocEvent {
  final DateTime date;
  const SelectDate(this.date);

  @override
  List<Object?> get props => [date];
}
