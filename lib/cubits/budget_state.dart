import 'package:equatable/equatable.dart';
import '../models/budget.dart';

abstract class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object> get props => [];
}

class BudgetInitial extends BudgetState {}

class BudgetLoaded extends BudgetState {
  final List<Budget> budgets;

  const BudgetLoaded({required this.budgets});

  @override
  List<Object> get props => [budgets];

  BudgetLoaded copyWith({List<Budget>? budgets}) {
    return BudgetLoaded(budgets: budgets ?? this.budgets);
  }
}