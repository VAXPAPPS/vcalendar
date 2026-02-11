import 'package:hive_flutter/hive_flutter.dart';
import '../models/event_model.dart';
import '../models/category_model.dart';

/// مصدر البيانات المحلي — Hive
class LocalDataSource {
  static const String eventsBoxName = 'events';
  static const String categoriesBoxName = 'categories';

  late Box<EventModel> _eventsBox;
  late Box<CategoryModel> _categoriesBox;

  /// تهيئة Hive وفتح الصناديق
  Future<void> init() async {
    await Hive.initFlutter();

    // تسجيل الـ Adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(EventModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CategoryModelAdapter());
    }

    // فتح الصناديق
    _eventsBox = await Hive.openBox<EventModel>(eventsBoxName);
    _categoriesBox = await Hive.openBox<CategoryModel>(categoriesBoxName);
  }

  // ==================== Events ====================

  List<EventModel> getAllEvents() {
    return _eventsBox.values.toList();
  }

  Future<void> addEvent(EventModel event) async {
    await _eventsBox.put(event.id, event);
  }

  Future<void> updateEvent(EventModel event) async {
    await _eventsBox.put(event.id, event);
  }

  Future<void> deleteEvent(String eventId) async {
    await _eventsBox.delete(eventId);
  }

  // ==================== Categories ====================

  List<CategoryModel> getAllCategories() {
    return _categoriesBox.values.toList();
  }

  Future<void> addCategory(CategoryModel category) async {
    await _categoriesBox.put(category.id, category);
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _categoriesBox.put(category.id, category);
  }

  Future<void> deleteCategory(String categoryId) async {
    await _categoriesBox.delete(categoryId);
  }

  bool isCategoriesEmpty() {
    return _categoriesBox.isEmpty;
  }
}
