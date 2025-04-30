import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionTile({Key? key, required this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        transaction.type == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
        color: transaction.type == 'income' ? Colors.green : Colors.red,
      ),
      title: Text(transaction.title),
      subtitle: Text(transaction.date.toLocal().toString().split(' ')[0]),
      trailing: Text(
        (transaction.type == 'income' ? '+' : '-') + '\$${transaction.amount.toStringAsFixed(2)}',
        style: TextStyle(
          color: transaction.type == 'income' ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
