import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/category.dart';
import '../services/supabase_service.dart';
import 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final SupabaseService _supabaseService = SupabaseService();

  CategoryCubit() : super(CategoryInitial()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final categories = await _supabaseService.getCategories();
      
      // If no categories, add default ones
      if (categories.isEmpty) {
        await _addDefaultCategories();
        final newCategories = await _supabaseService.getCategories();
        emit(CategoryLoaded(categories: newCategories));
      } else {
        emit(CategoryLoaded(categories: categories));
      }
    } catch (e) {
      emit(CategoryLoaded(categories: []));
    }
  }

  Future<void> _addDefaultCategories() async {
    final defaultCategories = [
      Category(id: '', name: 'Makanan', color: '#FF6B6B', icon: '🍔'),
      Category(id: '', name: 'Transport', color: '#4ECDC4', icon: '🚗'),
      Category(id: '', name: 'Belanja', color: '#45B7D1', icon: '🛒'),
      Category(id: '', name: 'Hiburan', color: '#FFA07A', icon: '🎮'),
      Category(id: '', name: 'Gaji', color: '#98D8C8', icon: '💰'),
      Category(id: '', name: 'Tagihan', color: '#F7DC6F', icon: '📄'),
    ];

    for (var category in defaultCategories) {
      await _supabaseService.addCategory(category);
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      final newCategory = await _supabaseService.addCategory(category);
      
      if (state is CategoryLoaded) {
        final currentState = state as CategoryLoaded;
        final updatedCategories = [...currentState.categories, newCategory];
        emit(currentState.copyWith(categories: updatedCategories));
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _supabaseService.deleteCategory(id);
      
      if (state is CategoryLoaded) {
        final currentState = state as CategoryLoaded;
        final updatedCategories = currentState.categories
            .where((c) => c.id != id)
            .toList();
        emit(currentState.copyWith(categories: updatedCategories));
      }
    } catch (e) {
      // Handle error
    }
  }
}