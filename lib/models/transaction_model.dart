class TransactionModel {
  final String title;
  final double amount;
  final DateTime date;
  final String type; // 'income' or 'expense'

  TransactionModel({
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
  });
}