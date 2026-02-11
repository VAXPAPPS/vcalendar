import '../../domain/entities/event_category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/local_datasource.dart';
import '../models/category_model.dart';

/// تنفيذ مستودع التصنيفات
class CategoryRepositoryImpl implements CategoryRepository {
  final LocalDataSource _dataSource;

  CategoryRepositoryImpl(this._dataSource);

  @override
  Future<List<EventCategory>> getAllCategories() async {
    final models = _dataSource.getAllCategories();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addCategory(EventCategory category) async {
    await _dataSource.addCategory(CategoryModel.fromEntity(category));
  }

  @override
  Future<void> updateCategory(EventCategory category) async {
    await _dataSource.updateCategory(CategoryModel.fromEntity(category));
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await _dataSource.deleteCategory(categoryId);
  }

  @override
  Future<void> initDefaults() async {
    if (_dataSource.isCategoriesEmpty()) {
      for (final category in EventCategory.defaults) {
        await _dataSource.addCategory(CategoryModel.fromEntity(category));
      }
    }
  }
}
