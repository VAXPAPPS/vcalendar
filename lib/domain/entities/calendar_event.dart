import 'package:equatable/equatable.dart';

/// أنواع التكرار للأحداث
enum RecurrenceType { none, daily, weekly, monthly, yearly }

/// كيان الحدث — الطبقة الأساسية (Domain)
class CalendarEvent extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String categoryId;
  final int colorValue;
  final RecurrenceType recurrence;
  final bool isAllDay;

  const CalendarEvent({
    required this.id,
    required this.title,
    this.description = '',
    required this.startTime,
    required this.endTime,
    this.categoryId = 'default',
    this.colorValue = 0xFF7AB1FF,
    this.recurrence = RecurrenceType.none,
    this.isAllDay = false,
  });

  CalendarEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? categoryId,
    int? colorValue,
    RecurrenceType? recurrence,
    bool? isAllDay,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      categoryId: categoryId ?? this.categoryId,
      colorValue: colorValue ?? this.colorValue,
      recurrence: recurrence ?? this.recurrence,
      isAllDay: isAllDay ?? this.isAllDay,
    );
  }

  @override
  List<Object?> get props => [
    id, title, description, startTime, endTime,
    categoryId, colorValue, recurrence, isAllDay,
  ];
}
