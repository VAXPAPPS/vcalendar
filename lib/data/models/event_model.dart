import 'package:hive/hive.dart';
import '../../domain/entities/calendar_event.dart';

/// Hive TypeAdapter للأحداث — تحويل يدوي بدون code generation
class EventModel extends HiveObject {
  String id;
  String title;
  String description;
  DateTime startTime;
  DateTime endTime;
  String categoryId;
  int colorValue;
  int recurrenceIndex;
  bool isAllDay;

  EventModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.startTime,
    required this.endTime,
    this.categoryId = 'default',
    this.colorValue = 0xFF7AB1FF,
    this.recurrenceIndex = 0,
    this.isAllDay = false,
  });

  /// تحويل من Domain Entity إلى Hive Model
  factory EventModel.fromEntity(CalendarEvent event) {
    return EventModel(
      id: event.id,
      title: event.title,
      description: event.description,
      startTime: event.startTime,
      endTime: event.endTime,
      categoryId: event.categoryId,
      colorValue: event.colorValue,
      recurrenceIndex: event.recurrence.index,
      isAllDay: event.isAllDay,
    );
  }

  /// تحويل من Hive Model إلى Domain Entity
  CalendarEvent toEntity() {
    return CalendarEvent(
      id: id,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      categoryId: categoryId,
      colorValue: colorValue,
      recurrence: RecurrenceType.values[recurrenceIndex],
      isAllDay: isAllDay,
    );
  }
}

/// TypeAdapter يدوي للأحداث
class EventModelAdapter extends TypeAdapter<EventModel> {
  @override
  final int typeId = 0;

  @override
  EventModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return EventModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String? ?? '',
      startTime: fields[3] as DateTime,
      endTime: fields[4] as DateTime,
      categoryId: fields[5] as String? ?? 'default',
      colorValue: fields[6] as int? ?? 0xFF7AB1FF,
      recurrenceIndex: fields[7] as int? ?? 0,
      isAllDay: fields[8] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, EventModel obj) {
    writer.writeByte(9); // number of fields
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.title);
    writer.writeByte(2);
    writer.write(obj.description);
    writer.writeByte(3);
    writer.write(obj.startTime);
    writer.writeByte(4);
    writer.write(obj.endTime);
    writer.writeByte(5);
    writer.write(obj.categoryId);
    writer.writeByte(6);
    writer.write(obj.colorValue);
    writer.writeByte(7);
    writer.write(obj.recurrenceIndex);
    writer.writeByte(8);
    writer.write(obj.isAllDay);
  }
}
