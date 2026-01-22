import 'package:equatable/equatable.dart';
import '../models/transaction.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  final String searchTerm;
  final String filterType;
  final String filterCategory;

  const TransactionLoaded({
    required this.transactions,
    this.searchTerm = '',
    this.filterType = 'all',
    this.filterCategory = 'all',
  });

  @override
  List<Object> get props => [transactions, searchTerm, filterType, filterCategory];

  TransactionLoaded copyWith({
    List<Transaction>? transactions,
    String? searchTerm,
    String? filterType,
    String? filterCategory,
  }) {
    return TransactionLoaded(
      transactions: transactions ?? this.transactions,
      searchTerm: searchTerm ?? this.searchTerm,
      filterType: filterType ?? this.filterType,
      filterCategory: filterCategory ?? this.filterCategory,
    );
  }

  List<Transaction> get filteredTransactions {
    return transactions.where((t) {
      final matchesSearch = t.note.toLowerCase().contains(searchTerm.toLowerCase()) ||
          t.category.toLowerCase().contains(searchTerm.toLowerCase());
      final matchesType = filterType == 'all' || t.type == filterType;
      final matchesCategory = filterCategory == 'all' || t.category == filterCategory;

      return matchesSearch && matchesType && matchesCategory;
    }).toList();
  }

  double get totalIncome {
    return transactions
        .where((t) => t.type == 'income')
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return transactions
        .where((t) => t.type == 'expense')
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get balance => totalIncome - totalExpense;

  Map<String, double> get expenseByCategory {
    final Map<String, double> result = {};
    for (var transaction in transactions.where((t) => t.type == 'expense')) {
      result[transaction.category] = 
          (result[transaction.category] ?? 0) + transaction.amount;
    }
    return result;
  }
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object> get props => [message];
}