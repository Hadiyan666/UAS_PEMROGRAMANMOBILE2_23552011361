import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/budget.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient _client;

  // Initialize Supabase
  Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  SupabaseClient get client => _client;

  // Get current user ID
  String? get currentUserId => _client.auth.currentUser?.id;

  // ============================================================
  // AUTHENTICATION
  // ============================================================

  Future<AuthResponse> signUp(String email, String password) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ============================================================
  // TRANSACTIONS
  // ============================================================

  Future<List<Transaction>> getTransactions() async {
    final response = await _client
        .from('transactions')
        .select()
        .eq('user_id', currentUserId!)
        .order('date', ascending: false);

    return (response as List)
        .map((json) => Transaction(
              id: json['id'],
              type: json['type'],
              amount: (json['amount'] as num).toDouble(),
              category: json['category'],
              note: json['note'] ?? '',
              date: DateTime.parse(json['date']),
            ))
        .toList();
  }

  Future<Transaction> addTransaction(Transaction transaction) async {
    final data = {
      'user_id': currentUserId,
      'type': transaction.type,
      'amount': transaction.amount,
      'category': transaction.category,
      'note': transaction.note,
      'date': transaction.date.toIso8601String().split('T')[0],
    };

    final response = await _client
        .from('transactions')
        .insert(data)
        .select()
        .single();

    return Transaction(
      id: response['id'],
      type: response['type'],
      amount: (response['amount'] as num).toDouble(),
      category: response['category'],
      note: response['note'] ?? '',
      date: DateTime.parse(response['date']),
    );
  }

  Future<void> deleteTransaction(String id) async {
    await _client
        .from('transactions')
        .delete()
        .eq('id', id)
        .eq('user_id', currentUserId!);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final data = {
      'type': transaction.type,
      'amount': transaction.amount,
      'category': transaction.category,
      'note': transaction.note,
      'date': transaction.date.toIso8601String().split('T')[0],
    };

    await _client
        .from('transactions')
        .update(data)
        .eq('id', transaction.id)
        .eq('user_id', currentUserId!);
  }

  // ============================================================
  // CATEGORIES
  // ============================================================

  Future<List<Category>> getCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .eq('user_id', currentUserId!);

    return (response as List)
        .map((json) => Category(
              id: json['id'],
              name: json['name'],
              icon: json['icon'],
              color: json['color'],
            ))
        .toList();
  }

  Future<Category> addCategory(Category category) async {
    final data = {
      'user_id': currentUserId,
      'name': category.name,
      'icon': category.icon,
      'color': category.color,
    };

    final response = await _client
        .from('categories')
        .insert(data)
        .select()
        .single();

    return Category(
      id: response['id'],
      name: response['name'],
      icon: response['icon'],
      color: response['color'],
    );
  }

  Future<void> deleteCategory(String id) async {
    await _client
        .from('categories')
        .delete()
        .eq('id', id)
        .eq('user_id', currentUserId!);
  }

  // ============================================================
  // BUDGETS
  // ============================================================

  Future<List<Budget>> getBudgets({int? month, int? year}) async {
    var query = _client
        .from('budgets')
        .select()
        .eq('user_id', currentUserId!);

    if (month != null) query = query.eq('month', month);
    if (year != null) query = query.eq('year', year);

    final response = await query;

    return (response as List)
        .map((json) => Budget(
              id: json['id'],
              category: json['category'],
              limit: (json['limit_amount'] as num).toDouble(),
              spent: (json['spent'] as num).toDouble(),
            ))
        .toList();
  }

  Future<Budget> addBudget(Budget budget, int month, int year) async {
    final data = {
      'user_id': currentUserId,
      'category': budget.category,
      'limit_amount': budget.limit,
      'spent': budget.spent,
      'month': month,
      'year': year,
    };

    final response = await _client
        .from('budgets')
        .insert(data)
        .select()
        .single();

    return Budget(
      id: response['id'],
      category: response['category'],
      limit: (response['limit_amount'] as num).toDouble(),
      spent: (response['spent'] as num).toDouble(),
    );
  }

  Future<void> deleteBudget(String id) async {
    await _client
        .from('budgets')
        .delete()
        .eq('id', id)
        .eq('user_id', currentUserId!);
  }

  Future<void> updateBudgetSpent(String budgetId, double newSpent) async {
    await _client
        .from('budgets')
        .update({'spent': newSpent})
        .eq('id', budgetId)
        .eq('user_id', currentUserId!);
  }
}