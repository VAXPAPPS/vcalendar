import 'package:hive/hive.dart';
import '../../domain/entities/event_category.dart';

/// Hive Model للتصنيفات
class CategoryModel extends HiveObject {
  String id;
  String name;
  int colorValue;
  String icon;

  CategoryModel({
    required this.id,
    required this.name,
    required this.colorValue,
    this.icon = '📅',
  });

  factory CategoryModel.fromEntity(EventCategory category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      colorValue: category.colorValue,
      icon: category.icon,
    );
  }

  EventCategory toEntity() {
    return EventCategory(
      id: id,
      name: name,
      colorValue: colorValue,
      icon: icon,
    );
  }
}

/// TypeAdapter يدوي للتصنيفات
class CategoryModelAdapter extends TypeAdapter<CategoryModel> {
  @override
  final int typeId = 1;

  @override
  CategoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return CategoryModel(
      id: fields[0] as String,
      name: fields[1] as String,
      colorValue: fields[2] as int,
      icon: fields[3] as String? ?? '📅',
    );
  }

  @override
  void write(BinaryWriter writer, CategoryModel obj) {
    writer.writeByte(4);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.name);
    writer.writeByte(2);
    writer.write(obj.colorValue);
    writer.writeByte(3);
    writer.write(obj.icon);
  }
}
