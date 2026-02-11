import 'package:equatable/equatable.dart';
import '../../domain/entities/event_category.dart';

/// أحداث BLoC التصنيفات
abstract class CategoryBlocEvent extends Equatable {
  const CategoryBlocEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryBlocEvent {}

class AddCategory extends CategoryBlocEvent {
  final EventCategory category;
  const AddCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class UpdateCategory extends CategoryBlocEvent {
  final EventCategory category;
  const UpdateCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class DeleteCategory extends CategoryBlocEvent {
  final String categoryId;
  const DeleteCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}
