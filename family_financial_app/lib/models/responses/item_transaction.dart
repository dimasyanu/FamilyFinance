import 'package:family_financial_app/models/responses/item_account.dart';
import 'package:family_financial_app/models/responses/item_category.dart';

class ItemTransaction {
  final String id;
  final String description;
  final double amount;
  final DateTime transactionDate;
  final ItemCategory category;
  final ItemAccount account;
  final String? notes;

  ItemTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.transactionDate,
    required this.category,
    required this.account,
    this.notes,
  });
}
