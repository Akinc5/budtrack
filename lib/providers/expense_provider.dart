import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseProvider with ChangeNotifier {
  double _totalExpense = 0.0;

  double get totalExpense => _totalExpense;

  ExpenseProvider() {
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('type', isEqualTo: 'expense')
        .get();

    double total = 0.0;
    for (var doc in snapshot.docs) {
      total += (doc['amount'] as num).toDouble();
    }

    _totalExpense = total;
    notifyListeners();
  }

  Future<void> addExpense(double amount) async {
    _totalExpense += amount;
    notifyListeners();
  }
}
