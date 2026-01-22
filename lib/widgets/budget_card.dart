import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../utils/currency_formatter.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;
  final Category? category;

  const BudgetCard({
    Key? key,
    required this.budget,
    this.category,
  }) : super(key: key);

  double get percentage => (budget.spent / budget.limit * 100).clamp(0, 100);
  
  Color get progressColor {
    if (percentage >= 100) return Colors.red;
    if (percentage >= 80) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final remaining = budget.limit - budget.spent;

    return Card(
      margin: EdgeInsets.all(8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  category?.icon ?? '📁',
                  style: TextStyle(fontSize: 32),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.category,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Budget Bulanan',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (percentage >= 80)
                  Icon(
                    Icons.warning_amber_rounded,
                    color: progressColor,
                    size: 24,
                  ),
              ],
            ),
            SizedBox(height: 16),
            
            // Spent Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Terpakai',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  CurrencyFormatter.format(budget.spent),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 10,
              ),
            ),
            SizedBox(height: 8),
            
            // Limit and Remaining
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Limit: ${CurrencyFormatter.format(budget.limit)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  '${remaining >= 0 ? 'Sisa' : 'Lebih'}: ${CurrencyFormatter.format(remaining.abs())}',
                  style: TextStyle(
                    fontSize: 12,
                    color: remaining >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            // Warning Message
            if (percentage >= 80) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: progressColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: progressColor,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        percentage >= 100 
                            ? 'Budget sudah habis!' 
                            : 'Budget hampir habis!',
                        style: TextStyle(
                          color: progressColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}