import 'package:family_financial_app/models/responses/item_category.dart';

class ItemBudget {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final double amount;
  final ItemCategory category;

  ItemBudget({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.amount,
    required this.category,
  });
}
