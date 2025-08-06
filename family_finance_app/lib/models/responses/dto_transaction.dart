import 'package:family_financial_app/models/responses/item_account.dart';
import 'package:family_financial_app/models/responses/item_category.dart';

class DtoTransaction {
  final String id;
  final String description;
  final double amount;
  final DateTime transactionDate;
  final int transactionType;
  final ItemCategory category;
  final ItemAccount account;
  final String? notes;

  final String createdAt;
  final String createdBy;
  final String updatedAt;
  final String updatedBy;

  DtoTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.transactionDate,
    required this.transactionType,
    required this.category,
    required this.account,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    this.notes,
  });

  factory DtoTransaction.fromJson(Map<String, dynamic> json) {
    return DtoTransaction(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      transactionType: json['transactionType'] as int,
      category: ItemCategory.fromJson(json['category']),
      account: ItemAccount.fromJson(json['account']),
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as String,
      createdBy: json['createdBy'] as String,
      updatedAt: json['updatedAt'] as String,
      updatedBy: json['updatedBy'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'transactionDate': transactionDate.toIso8601String(),
      'transactionType': transactionType,
      'category': category.toJson(),
      'account': account.toJson(),
      'notes': notes,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'updatedAt': updatedAt,
      'updatedBy': updatedBy,
    };
  }
}
