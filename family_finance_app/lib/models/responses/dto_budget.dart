import 'package:family_financial_app/models/responses/dto_category.dart';
import 'package:family_financial_app/plugins/utils.dart';

class DtoBudget {
  final int id;
  final double amount;
  final int month;
  final int year;
  final DtoCategory? category;
  late final String period;

  DtoBudget({
    required this.id,
    required this.amount,
    required this.month,
    required this.year,
    this.category,
  }) : period = '${Utils.getMonthName(month)} $year';

  factory DtoBudget.fromJson(Map<String, dynamic> json) {
    return DtoBudget(
      id: json['id'] as int,
      amount: (json['amount'] as num).toDouble(),
      month: json['month'] as int,
      year: json['year'] as int,
      category: DtoCategory.fromJson(json['category'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'month': month,
      'year': year,
      'category': category?.toJson(),
    };
  }
}
