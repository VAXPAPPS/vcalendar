import '../../domain/entities/calendar_event.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/local_datasource.dart';
import '../models/event_model.dart';

/// تنفيذ مستودع الأحداث — يربط Domain بـ Data
class EventRepositoryImpl implements EventRepository {
  final LocalDataSource _dataSource;

  EventRepositoryImpl(this._dataSource);

  @override
  Future<List<CalendarEvent>> getAllEvents() async {
    final models = _dataSource.getAllEvents();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<CalendarEvent>> getEventsForDate(DateTime date) async {
    final allEvents = _dataSource.getAllEvents();
    return allEvents
        .where((e) {
          final eventDate = DateTime(
            e.startTime.year,
            e.startTime.month,
            e.startTime.day,
          );
          final targetDate = DateTime(date.year, date.month, date.day);
          return eventDate == targetDate;
        })
        .map((m) => m.toEntity())
        .toList();
  }

  @override
  Future<List<CalendarEvent>> getEventsForRange(
    DateTime start,
    DateTime end,
  ) async {
    final allEvents = _dataSource.getAllEvents();
    final rangeStart = DateTime(start.year, start.month, start.day);
    final rangeEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);

    return allEvents
        .where((e) {
          return !e.startTime.isBefore(rangeStart) &&
              !e.startTime.isAfter(rangeEnd);
        })
        .map((m) => m.toEntity())
        .toList();
  }

  @override
  Future<void> addEvent(CalendarEvent event) async {
    await _dataSource.addEvent(EventModel.fromEntity(event));
  }

  @override
  Future<void> updateEvent(CalendarEvent event) async {
    await _dataSource.updateEvent(EventModel.fromEntity(event));
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await _dataSource.deleteEvent(eventId);
  }

  @override
  Future<List<CalendarEvent>> searchEvents(String query) async {
    final allEvents = _dataSource.getAllEvents();
    final lowerQuery = query.toLowerCase();
    return allEvents
        .where(
          (e) =>
              e.title.toLowerCase().contains(lowerQuery) ||
              e.description.toLowerCase().contains(lowerQuery),
        )
        .map((m) => m.toEntity())
        .toList();
  }
}
