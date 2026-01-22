import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/transaction_cubit.dart';
import '../cubits/transaction_state.dart';
import '../cubits/category_cubit.dart';
import '../cubits/category_state.dart';
import '../widgets/transaction_card.dart';
import 'add_transaction_screen.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, transactionState) {
        if (transactionState is TransactionLoaded) {
          return Column(
            children: [
              // Filter Section
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  children: [
                    // Search
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari transaksi...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        context.read<TransactionCubit>().updateSearchTerm(value);
                      },
                    ),
                    SizedBox(height: 12),
                    
                    // Filters
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Tipe',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            value: transactionState.filterType,
                            items: [
                              DropdownMenuItem(value: 'all', child: Text('Semua')),
                              DropdownMenuItem(value: 'income', child: Text('Pemasukan')),
                              DropdownMenuItem(value: 'expense', child: Text('Pengeluaran')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                context.read<TransactionCubit>().updateFilterType(value);
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: BlocBuilder<CategoryCubit, CategoryState>(
                            builder: (context, categoryState) {
                              if (categoryState is CategoryLoaded) {
                                return DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'Kategori',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  value: transactionState.filterCategory,
                                  items: [
                                    DropdownMenuItem(value: 'all', child: Text('Semua')),
                                    ...categoryState.categories.map((cat) => 
                                      DropdownMenuItem(
                                        value: cat.name,
                                        child: Text(cat.name),
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      context.read<TransactionCubit>().updateFilterCategory(value);
                                    }
                                  },
                                );
                              }
                              return SizedBox();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Add Transaction Button
              Padding(
                padding: EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddTransactionScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.add),
                  label: Text('Tambah Transaksi Baru'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
              ),

              // Transaction Count
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Menampilkan ${transactionState.filteredTransactions.length} transaksi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),

              // Transaction List
              Expanded(
                child: BlocBuilder<CategoryCubit, CategoryState>(
                  builder: (context, categoryState) {
                    if (categoryState is CategoryLoaded) {
                      final filteredTransactions = transactionState.filteredTransactions;
                      
                      if (filteredTransactions.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Tidak ada transaksi',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = filteredTransactions[index];
                          final category = categoryState.categories.firstWhere(
                            (cat) => cat.name == transaction.category,
                            orElse: () => categoryState.categories.first,
                          );

                          return TransactionCard(
                            transaction: transaction,
                            category: category,
                            onDelete: () {
                              context.read<TransactionCubit>().deleteTransaction(transaction.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Transaksi dihapus')),
                              );
                            },
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
}