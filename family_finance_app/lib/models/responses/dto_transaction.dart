import 'package:family_financial_app/models/responses/item_account.dart';
import 'package:family_financial_app/models/responses/item_category.dart';

class DtoTransaction {
  final String id;
  final String description;
  final double amount;
  final DateTime transactionDate;
  final ItemCategory category;
  final ItemAccount account;
  final String? notes;

  DtoTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.transactionDate,
    required this.category,
    required this.account,
    this.notes,
  });

  factory DtoTransaction.fromJson(Map<String, dynamic> json) {
    return DtoTransaction(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      category: ItemCategory.fromJson(json['category']),
      account: ItemAccount.fromJson(json['account']),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'transactionDate': transactionDate.toIso8601String(),
      'category': category.toJson(),
      'account': account.toJson(),
      'notes': notes,
    };
  }
}
