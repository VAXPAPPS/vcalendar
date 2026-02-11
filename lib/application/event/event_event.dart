import 'package:equatable/equatable.dart';
import '../../domain/entities/calendar_event.dart';

/// أحداث BLoC إدارة الأحداث
abstract class EventBlocEvent extends Equatable {
  const EventBlocEvent();

  @override
  List<Object?> get props => [];
}

/// تحميل أحداث نطاق زمني
class LoadEvents extends EventBlocEvent {
  final DateTime start;
  final DateTime end;
  const LoadEvents({required this.start, required this.end});

  @override
  List<Object?> get props => [start, end];
}

/// تحميل أحداث يوم محدد
class LoadEventsForDate extends EventBlocEvent {
  final DateTime date;
  const LoadEventsForDate(this.date);

  @override
  List<Object?> get props => [date];
}

/// إضافة حدث جديد
class AddEvent extends EventBlocEvent {
  final CalendarEvent event;
  const AddEvent(this.event);

  @override
  List<Object?> get props => [event];
}

/// تحديث حدث
class UpdateEvent extends EventBlocEvent {
  final CalendarEvent event;
  const UpdateEvent(this.event);

  @override
  List<Object?> get props => [event];
}

/// حذف حدث
class DeleteEvent extends EventBlocEvent {
  final String eventId;
  const DeleteEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

/// بحث في الأحداث
class SearchEvents extends EventBlocEvent {
  final String query;
  const SearchEvents(this.query);

  @override
  List<Object?> get props => [query];
}
