import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/transaction_cubit.dart';
import '../cubits/transaction_state.dart';
import '../cubits/category_cubit.dart';
import '../cubits/category_state.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_card.dart';
import 'add_transaction_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, transactionState) {
        if (transactionState is TransactionLoaded) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Balance Cards
                Container(
                  color: Colors.green,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: BalanceCard(
                              title: 'Saldo',
                              amount: transactionState.balance,
                              icon: Icons.account_balance_wallet,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: BalanceCard(
                              title: 'Pemasukan',
                              amount: transactionState.totalIncome,
                              icon: Icons.trending_up,
                              color: Colors.green[700]!,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: BalanceCard(
                              title: 'Pengeluaran',
                              amount: transactionState.totalExpense,
                              icon: Icons.trending_down,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Quick Actions
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
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
                              label: Text('Tambah Transaksi'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Recent Transactions
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transaksi Terbaru',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to transaction screen
                        },
                        child: Text('Lihat Semua'),
                      ),
                    ],
                  ),
                ),

                BlocBuilder<CategoryCubit, CategoryState>(
                  builder: (context, categoryState) {
                    if (categoryState is CategoryLoaded) {
                      final recentTransactions = transactionState.transactions.take(5).toList();
                      
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: recentTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = recentTransactions[index];
                          final category = categoryState.categories.firstWhere(
                            (cat) => cat.name == transaction.category,
                            orElse: () => categoryState.categories.first,
                          );

                          return TransactionCard(
                            transaction: transaction,
                            category: category,
                            onDelete: () {
                              context.read<TransactionCubit>().deleteTransaction(transaction.id);
                            },
                          );
                        },
                      );
                    }
                    return SizedBox();
                  },
                ),
                SizedBox(height: 16),
              ],
            ),
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}