import 'package:equatable/equatable.dart';
import '../../domain/entities/calendar_event.dart';

/// حالات BLoC الأحداث
abstract class EventState extends Equatable {
  const EventState();

  @override
  List<Object?> get props => [];
}

/// الحالة الابتدائية
class EventInitial extends EventState {}

/// جاري التحميل
class EventLoading extends EventState {}

/// تم تحميل الأحداث بنجاح
class EventLoaded extends EventState {
  final List<CalendarEvent> events;
  final Map<String, List<CalendarEvent>> eventsByDate;

  const EventLoaded({required this.events, required this.eventsByDate});

  @override
  List<Object?> get props => [events, eventsByDate];
}

/// حالة نتائج البحث
class EventSearchResults extends EventState {
  final List<CalendarEvent> results;
  final String query;

  const EventSearchResults({required this.results, required this.query});

  @override
  List<Object?> get props => [results, query];
}

/// حدث خطأ
class EventError extends EventState {
  final String message;
  const EventError(this.message);

  @override
  List<Object?> get props => [message];
}

/// تم تنفيذ العملية بنجاح (إضافة/تعديل/حذف)
class EventOperationSuccess extends EventState {
  final String message;
  const EventOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
