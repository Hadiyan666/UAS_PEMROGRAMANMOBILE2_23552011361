import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../cubits/transaction_cubit.dart';
import '../cubits/transaction_state.dart';
import '../cubits/category_cubit.dart';
import '../cubits/category_state.dart';
import '../utils/currency_formatter.dart';
import '../utils/colors.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, transactionState) {
        if (transactionState is TransactionLoaded) {
          final expenseByCategory = transactionState.expenseByCategory;

          if (expenseByCategory.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pie_chart, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada data statistik',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pie Chart Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pengeluaran per Kategori',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 24),
                        SizedBox(
                          height: 250,
                          child: BlocBuilder<CategoryCubit, CategoryState>(
                            builder: (context, categoryState) {
                              if (categoryState is CategoryLoaded) {
                                final sections = expenseByCategory.entries.map((entry) {
                                  final category = categoryState.categories.firstWhere(
                                    (cat) => cat.name == entry.key,
                                    orElse: () => categoryState.categories.first,
                                  );
                                  final percentage = (entry.value / transactionState.totalExpense * 100);
                                  
                                  return PieChartSectionData(
                                    value: entry.value,
                                    title: '${percentage.toStringAsFixed(0)}%',
                                    color: _hexToColor(category.color),
                                    radius: 100,
                                    titleStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                }).toList();

                                return PieChart(
                                  PieChartData(
                                    sections: sections,
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 40,
                                  ),
                                );
                              }
                              return Center(child: CircularProgressIndicator());
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Detail Breakdown
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detail Pengeluaran',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        BlocBuilder<CategoryCubit, CategoryState>(
                          builder: (context, categoryState) {
                            if (categoryState is CategoryLoaded) {
                              final sortedEntries = expenseByCategory.entries.toList()
                                ..sort((a, b) => b.value.compareTo(a.value));

                              return Column(
                                children: sortedEntries.map((entry) {
                                  final category = categoryState.categories.firstWhere(
                                    (cat) => cat.name == entry.key,
                                    orElse: () => categoryState.categories.first,
                                  );
                                  final percentage = (entry.value / transactionState.totalExpense * 100);
                                  
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  category.icon,
                                                  style: TextStyle(fontSize: 24),
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  entry.key,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              CurrencyFormatter.format(entry.value),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: LinearProgressIndicator(
                                            value: percentage / 100,
                                            backgroundColor: Colors.grey[200],
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              _hexToColor(category.color),
                                            ),
                                            minHeight: 10,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '${percentage.toStringAsFixed(1)}% dari total pengeluaran',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            }
                            return Center(child: CircularProgressIndicator());
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Summary Card
                SizedBox(height: 16),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ringkasan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildSummaryRow(
                          'Total Pemasukan',
                          CurrencyFormatter.format(transactionState.totalIncome),
                          Colors.green,
                        ),
                        Divider(),
                        _buildSummaryRow(
                          'Total Pengeluaran',
                          CurrencyFormatter.format(transactionState.totalExpense),
                          Colors.red,
                        ),
                        Divider(),
                        _buildSummaryRow(
                          'Saldo',
                          CurrencyFormatter.format(transactionState.balance),
                          transactionState.balance >= 0 ? Colors.blue : Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}