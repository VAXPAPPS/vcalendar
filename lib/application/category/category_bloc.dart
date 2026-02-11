import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

/// BLoC التصنيفات
class CategoryBloc extends Bloc<CategoryBlocEvent, CategoryState> {
  final CategoryRepository _repository;

  CategoryBloc(this._repository) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoad);
    on<AddCategory>(_onAdd);
    on<UpdateCategory>(_onUpdate);
    on<DeleteCategory>(_onDelete);
  }

  Future<void> _onLoad(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final categories = await _repository.getAllCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onAdd(
    AddCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _repository.addCategory(event.category);
      final categories = await _repository.getAllCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onUpdate(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _repository.updateCategory(event.category);
      final categories = await _repository.getAllCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _repository.deleteCategory(event.categoryId);
      final categories = await _repository.getAllCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
