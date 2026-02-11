import 'package:equatable/equatable.dart';

/// كيان تصنيف الأحداث
class EventCategory extends Equatable {
  final String id;
  final String name;
  final int colorValue;
  final String icon;

  const EventCategory({
    required this.id,
    required this.name,
    required this.colorValue,
    this.icon = '📅',
  });

  EventCategory copyWith({
    String? id,
    String? name,
    int? colorValue,
    String? icon,
  }) {
    return EventCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      icon: icon ?? this.icon,
    );
  }

  /// التصنيفات الافتراضية
  static const List<EventCategory> defaults = [
    EventCategory(id: 'work', name: 'عمل', colorValue: 0xFF4A90D9, icon: '💼'),
    EventCategory(id: 'personal', name: 'شخصي', colorValue: 0xFF28C840, icon: '👤'),
    EventCategory(id: 'meeting', name: 'اجتماع', colorValue: 0xFFFF9500, icon: '🤝'),
    EventCategory(id: 'important', name: 'مهم', colorValue: 0xFFFF5F57, icon: '⭐'),
    EventCategory(id: 'default', name: 'عام', colorValue: 0xFF7AB1FF, icon: '📅'),
  ];

  @override
  List<Object?> get props => [id, name, colorValue, icon];
}
