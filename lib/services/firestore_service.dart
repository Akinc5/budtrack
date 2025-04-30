import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetches income, expense, and category breakdown for a given month.
  Future<Map<String, dynamic>> getMonthlySummary(String monthYear) async {
    double incomeTotal = 0;
    double expenseTotal = 0;
    Map<String, double> categoryBreakdown = {};

    // Fetch income
    final incomeSnapshot = await _db
        .collection('income')
        .where('month', isEqualTo: monthYear)
        .get();

    for (var doc in incomeSnapshot.docs) {
      final amount = (doc.data()['amount'] ?? 0).toDouble();
      incomeTotal += amount;
    }

    // Fetch expenses
    final expenseSnapshot = await _db
        .collection('expenses')
        .where('month', isEqualTo: monthYear)
        .get();

    for (var doc in expenseSnapshot.docs) {
      final data = doc.data();
      final amount = (data['amount'] ?? 0).toDouble();
      final category = data['category'] ?? 'Other';

      expenseTotal += amount;
      categoryBreakdown[category] =
          (categoryBreakdown[category] ?? 0) + amount;
    }

    return {
      'incomeTotal': incomeTotal,
      'expenseTotal': expenseTotal,
      'categoryBreakdown': categoryBreakdown,
    };
  }

  /// Adds a custom expense category for the current user.
  Future<void> addCategory(String name, String userId) async {
    await _db.collection('categories').add({
      'name': name.trim(),
      'userId': userId,
      'createdAt': Timestamp.now(),
    });
  }

  /// Retrieves all custom categories for a user.
  Future<List<String>> getUserCategories(String userId) async {
    final snapshot = await _db
        .collection('categories')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => doc.data()['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  /// Deletes a user-created category by its Firestore document ID.
  Future<void> deleteCategory(String categoryId) async {
    await _db.collection('categories').doc(categoryId).delete();
  }

  /// (Optional) Initialize predefined categories for a user if none exist
  Future<void> initializeDefaultCategories(String userId) async {
    final snapshot = await _db
        .collection('categories')
        .where('userId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isEmpty) {
      const defaultCategories = [
        'Groceries',
        'Bills',
        'Entertainment',
        'Transport',
        'Health',
        'Education',
        'Rent',
        'Subscriptions',
        'Dining Out',
        'Shopping',
        'Travel',
        'Others',
      ];

      final batch = _db.batch();

      for (var name in defaultCategories) {
        final docRef = _db.collection('categories').doc();
        batch.set(docRef, {
          'name': name,
          'userId': userId,
          'createdAt': Timestamp.now(),
        });
      }

      await batch.commit();
    }
  }
}
