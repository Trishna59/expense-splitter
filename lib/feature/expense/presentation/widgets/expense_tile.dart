// lib/feature/expense/presentation/widgets/expense_tile.dart

import 'package:flutter/material.dart';
import 'package:expenses_splitter/feature/expense/data/models/expense_model.dart';

class ExpenseTile extends StatelessWidget {
  final ExpenseModel expense;
  final String currentUserId;
  final String currency;

  const ExpenseTile({
    super.key,
    required this.expense,
    required this.currentUserId,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final isPayer = expense.paidBy == currentUserId;
    final myShare = expense.splits[currentUserId] ?? 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        // Icon based on category (simple for now)
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.shade100,
          child: const Icon(Icons.receipt_outlined, color: Colors.deepPurple),
        ),

        // Title and who paid
        title: Text(
          expense.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Paid by ${isPayer ? 'you' : expense.paidByName} · '
          '${expense.date.day}/${expense.date.month}/${expense.date.year}',
          style: const TextStyle(fontSize: 12),
        ),

        // Right side — total amount and your share
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$currency ${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              isPayer
                  ? 'you paid'
                  : 'your share: $currency ${myShare.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 11,
                color: isPayer ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}