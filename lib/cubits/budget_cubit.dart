import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/budget.dart';
import '../services/supabase_service.dart';
import 'budget_state.dart';

class BudgetCubit extends Cubit<BudgetState> {
  final SupabaseService _supabaseService = SupabaseService();

  BudgetCubit() : super(BudgetInitial()) {
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    try {
      final now = DateTime.now();
      final budgets = await _supabaseService.getBudgets(
        month: now.month,
        year: now.year,
      );
      
      emit(BudgetLoaded(budgets: budgets));
    } catch (e) {
      emit(BudgetLoaded(budgets: []));
    }
  }

  Future<void> addBudget(Budget budget) async {
    try {
      final now = DateTime.now();
      final newBudget = await _supabaseService.addBudget(
        budget,
        now.month,
        now.year,
      );
      
      if (state is BudgetLoaded) {
        final currentState = state as BudgetLoaded;
        final updatedBudgets = [...currentState.budgets, newBudget];
        emit(currentState.copyWith(budgets: updatedBudgets));
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateBudgetSpent(String category, double amount) async {
    if (state is BudgetLoaded) {
      final currentState = state as BudgetLoaded;
      final budget = currentState.budgets.firstWhere(
        (b) => b.category == category,
        orElse: () => Budget(id: '', category: '', limit: 0, spent: 0),
      );

      if (budget.id.isNotEmpty) {
        final newSpent = budget.spent + amount;
        await _supabaseService.updateBudgetSpent(budget.id, newSpent);
        
        final updatedBudgets = currentState.budgets.map((b) {
          if (b.id == budget.id) {
            return b.copyWith(spent: newSpent);
          }
          return b;
        }).toList();
        
        emit(currentState.copyWith(budgets: updatedBudgets));
      }
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      await _supabaseService.deleteBudget(id);
      
      if (state is BudgetLoaded) {
        final currentState = state as BudgetLoaded;
        final updatedBudgets = currentState.budgets
            .where((b) => b.id != id)
            .toList();
        emit(currentState.copyWith(budgets: updatedBudgets));
      }
    } catch (e) {
      // Handle error
    }
  }
}