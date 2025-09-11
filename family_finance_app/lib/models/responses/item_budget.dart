import 'package:family_financial_app/models/responses/item_category.dart';
import 'package:family_financial_app/plugins/utils.dart';

class ItemBudget {
  final int id;
  final int month;
  final int year;
  final double amount;
  final ItemCategory category;
  late final String period;

  ItemBudget({
    required this.id,
    required this.month,
    required this.year,
    required this.amount,
    required this.category,
  }) : period = '${Utils.getMonthName(month)} $year';

  factory ItemBudget.fromJson(Map<String, dynamic> json) {
    return ItemBudget(
      id: json['id'] as int,
      month: json['month'] as int,
      year: json['year'] as int,
      amount: (json['amount'] as num).toDouble(),
      category: ItemCategory.fromJson(json['category'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'month': month,
      'year': year,
      'amount': amount,
      'category': category.toJson(),
    };
  }
}
