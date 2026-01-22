import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/transaction.dart';
import '../services/supabase_service.dart';
import 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final SupabaseService _supabaseService = SupabaseService();

  TransactionCubit() : super(TransactionInitial()) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    try {
      emit(TransactionLoading());
      
      final transactions = await _supabaseService.getTransactions();
      
      emit(TransactionLoaded(transactions: transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      final newTransaction = await _supabaseService.addTransaction(transaction);
      
      if (state is TransactionLoaded) {
        final currentState = state as TransactionLoaded;
        final updatedTransactions = [newTransaction, ...currentState.transactions];
        emit(currentState.copyWith(transactions: updatedTransactions));
      }
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _supabaseService.deleteTransaction(id);
      
      if (state is TransactionLoaded) {
        final currentState = state as TransactionLoaded;
        final updatedTransactions = currentState.transactions
            .where((t) => t.id != id)
            .toList();
        emit(currentState.copyWith(transactions: updatedTransactions));
      }
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  void updateSearchTerm(String term) {
    if (state is TransactionLoaded) {
      final currentState = state as TransactionLoaded;
      emit(currentState.copyWith(searchTerm: term));
    }
  }

  void updateFilterType(String type) {
    if (state is TransactionLoaded) {
      final currentState = state as TransactionLoaded;
      emit(currentState.copyWith(filterType: type));
    }
  }

  void updateFilterCategory(String category) {
    if (state is TransactionLoaded) {
      final currentState = state as TransactionLoaded;
      emit(currentState.copyWith(filterCategory: category));
    }
  }
}