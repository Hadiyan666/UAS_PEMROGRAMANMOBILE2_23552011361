import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/budget_cubit.dart';
import '../cubits/budget_state.dart';
import '../cubits/category_cubit.dart';
import '../cubits/category_state.dart';
import '../widgets/budget_card.dart';
import '../models/budget.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetCubit, BudgetState>(
      builder: (context, budgetState) {
        if (budgetState is BudgetLoaded) {
          return Column(
            children: [
              // Add Budget Button
              Padding(
                padding: EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showAddBudgetDialog(context);
                  },
                  icon: Icon(Icons.add),
                  label: Text('Tambah Budget Baru'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
              ),

              // Budget List
              Expanded(
                child: budgetState.budgets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.account_balance, size: 80, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Belum ada budget',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : BlocBuilder<CategoryCubit, CategoryState>(
                        builder: (context, categoryState) {
                          if (categoryState is CategoryLoaded) {
                            return GridView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
                                childAspectRatio: 1.5,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: budgetState.budgets.length,
                              itemBuilder: (context, index) {
                                final budget = budgetState.budgets[index];
                                final category = categoryState.categories.firstWhere(
                                  (cat) => cat.name == budget.category,
                                  orElse: () => categoryState.categories.first,
                                );

                                return BudgetCard(
                                  budget: budget,
                                  category: category,
                                );
                              },
                            );
                          }
                          return Center(child: CircularProgressIndicator());
                        },
                      ),
              ),
            ],
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  void _showAddBudgetDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String? selectedCategory;
    final limitController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Tambah Budget'),
        content: BlocProvider.value(
          value: context.read<CategoryCubit>(),
          child: BlocBuilder<CategoryCubit, CategoryState>(
            builder: (context, categoryState) {
              if (categoryState is CategoryLoaded) {
                // Get categories that don't have budget yet
                final budgetState = dialogContext.read<BudgetCubit>().state;
                final existingCategories = budgetState is BudgetLoaded
                    ? budgetState.budgets.map((b) => b.category).toList()
                    : <String>[];
                
                final availableCategories = categoryState.categories
                    .where((cat) => !existingCategories.contains(cat.name))
                    .toList();

                return Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Kategori',
                          border: OutlineInputBorder(),
                        ),
                        items: availableCategories.map((cat) {
                          return DropdownMenuItem(
                            value: cat.name,
                            child: Row(
                              children: [
                                Text(cat.icon, style: TextStyle(fontSize: 20)),
                                SizedBox(width: 8),
                                Text(cat.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          selectedCategory = value;
                        },
                        validator: (value) {
                          if (value == null) return 'Kategori harus dipilih';
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: limitController,
                        decoration: InputDecoration(
                          labelText: 'Limit Budget',
                          prefixText: 'Rp ',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Limit harus diisi';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Limit harus berupa angka';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                );
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate() && selectedCategory != null) {
                final budget = Budget(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  category: selectedCategory!,
                  limit: double.parse(limitController.text),
                  spent: 0,
                );

                context.read<BudgetCubit>().addBudget(budget);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Budget berhasil ditambahkan')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }
}