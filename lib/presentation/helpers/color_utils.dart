import 'package:flutter/material.dart';

/// دوال مساعدة للألوان
class ColorUtils {
  /// تحويل قيمة int إلى Color
  static Color fromValue(int value) => Color(value);

  /// ألوان متاحة لاختيار لون الحدث
  static const List<int> availableColors = [
    0xFF4A90D9, // أزرق
    0xFF28C840, // أخضر
    0xFFFF9500, // برتقالي
    0xFFFF5F57, // أحمر
    0xFF7AB1FF, // أزرق فاتح
    0xFFAF52DE, // بنفسجي
    0xFFFF2D55, // وردي
    0xFF5AC8FA, // سماوي
    0xFFFFCC00, // أصفر
    0xFF34C759, // أخضر فاتح
    0xFFFF6B35, // برتقالي غامق
    0xFF8E8E93, // رمادي
  ];
}
