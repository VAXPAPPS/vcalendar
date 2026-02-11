import '../entities/event_category.dart';

/// واجهة مستودع التصنيفات (Domain Layer)
abstract class CategoryRepository {
  /// جلب جميع التصنيفات
  Future<List<EventCategory>> getAllCategories();

  /// إضافة تصنيف جديد
  Future<void> addCategory(EventCategory category);

  /// تحديث تصنيف
  Future<void> updateCategory(EventCategory category);

  /// حذف تصنيف
  Future<void> deleteCategory(String categoryId);

  /// تهيئة التصنيفات الافتراضية
  Future<void> initDefaults();
}
