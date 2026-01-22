import 'package:equatable/equatable.dart';
import '../models/category.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;

  const CategoryLoaded({required this.categories});

  @override
  List<Object> get props => [categories];

  CategoryLoaded copyWith({List<Category>? categories}) {
    return CategoryLoaded(
      categories: categories ?? this.categories,
    );
  }
}