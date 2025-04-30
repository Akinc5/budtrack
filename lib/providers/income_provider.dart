import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IncomeProvider with ChangeNotifier {
  double _totalIncome = 0.0;

  double get totalIncome => _totalIncome;

  IncomeProvider() {
    _fetchIncomes();
  }

  Future<void> _fetchIncomes() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('type', isEqualTo: 'income')
        .get();

    double total = 0.0;
    for (var doc in snapshot.docs) {
      total += (doc['amount'] as num).toDouble();
    }

    _totalIncome = total;
    notifyListeners();
  }

  Future<void> addIncome(double amount) async {
    _totalIncome += amount;
    notifyListeners();
  }
}
