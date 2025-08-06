import 'package:family_financial_app/constants/transaction_type.dart';

class ItemTransaction {
  final String id;
  final String description;
  final double amount;
  final DateTime transactionDate;
  final int transactionType;
  final String category;
  final String account;
  final String? notes;

  ItemTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.transactionDate,
    required this.transactionType,
    required this.category,
    required this.account,
    this.notes,
  });

  factory ItemTransaction.fromJson(Map<String, dynamic> json) {
    return ItemTransaction(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      transactionType: json['transactionType'] as int,
      category: json['category'] as String,
      account: json['account'] as String,
      notes: json['notes'] as String?,
    );
  }
}
