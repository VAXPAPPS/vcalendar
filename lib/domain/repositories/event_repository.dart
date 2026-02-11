import '../entities/calendar_event.dart';

/// واجهة مستودع الأحداث (Domain Layer)
abstract class EventRepository {
  /// جلب جميع الأحداث
  Future<List<CalendarEvent>> getAllEvents();

  /// جلب أحداث تاريخ معين
  Future<List<CalendarEvent>> getEventsForDate(DateTime date);

  /// جلب أحداث نطاق زمني (شهر/أسبوع)
  Future<List<CalendarEvent>> getEventsForRange(DateTime start, DateTime end);

  /// إضافة حدث جديد
  Future<void> addEvent(CalendarEvent event);

  /// تحديث حدث موجود
  Future<void> updateEvent(CalendarEvent event);

  /// حذف حدث
  Future<void> deleteEvent(String eventId);

  /// البحث في الأحداث
  Future<List<CalendarEvent>> searchEvents(String query);
}
