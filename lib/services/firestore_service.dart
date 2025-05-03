import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Adds an income record
  Future<void> addIncome(Map<String, dynamic> data, String userId) async {
    await _db.collection('income').add({
      ...data,
      'userId': userId,
      'createdAt': Timestamp.now(),
    });
  }

  /// Adds an expense record
  Future<void> addExpense(Map<String, dynamic> data, String userId) async {
    await _db.collection('expenses').add({
      ...data,
      'userId': userId,
      'createdAt': Timestamp.now(),
    });
  }

  /// Adds a new category for the user
  Future<void> addCategory(String categoryName, String userId) async {
    await _db.collection('categories').add({
      'name': categoryName,
      'userId': userId,
      'createdAt': Timestamp.now(),
    });
  }

  /// Fetches the list of user categories
  Future<List<String>> getUserCategories(String userId) async {
    final snapshot = await _db
        .collection('categories')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) => doc['name'] as String).toList();
  }

  /// Initializes default categories for new users
  Future<void> initializeDefaultCategories(String userId) async {
    final currentCategories = await getUserCategories(userId);
    if (currentCategories.isNotEmpty) return;

    const defaultCategories = ['Food', 'Transport', 'Utilities', 'Shopping', 'Others'];
    for (final category in defaultCategories) {
      await addCategory(category, userId);
    }
  }

  /// Fetches monthly summary: income, expense, and category breakdown
  Future<Map<String, dynamic>> getMonthlySummary(String monthYear, String userId) async {
    double incomeTotal = 0;
    double expenseTotal = 0;
    Map<String, double> categoryBreakdown = {};

    // Fetch income
    final incomeSnapshot = await _db
        .collection('income')
        .where('month', isEqualTo: monthYear)
        .where('userId', isEqualTo: userId)
        .get();

    for (var doc in incomeSnapshot.docs) {
      final data = doc.data();
      incomeTotal += (data['amount'] ?? 0).toDouble();
    }

    // Fetch expenses
    final expenseSnapshot = await _db
        .collection('expenses')
        .where('month', isEqualTo: monthYear)
        .where('userId', isEqualTo: userId)
        .get();

    for (var doc in expenseSnapshot.docs) {
      final data = doc.data();
      final amount = (data['amount'] ?? 0).toDouble();
      final category = data['category'] ?? 'Other';

      expenseTotal += amount;
      categoryBreakdown[category] = (categoryBreakdown[category] ?? 0) + amount;
    }

    return {
      'incomeTotal': incomeTotal,
      'expenseTotal': expenseTotal,
      'categoryBreakdown': categoryBreakdown,
    };
  }

  /// Saves or updates user info by phone number
  Future<void> saveUser(String phoneNumber) async {
    final userDoc = _db.collection('users').doc(phoneNumber);

    final doc = await userDoc.get();
    if (!doc.exists) {
      await userDoc.set({
        'phoneNumber': phoneNumber,
        'createdAt': Timestamp.now(),
      });
      print('User saved with phone number: $phoneNumber');
    }
  }
}
