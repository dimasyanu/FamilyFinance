import 'package:family_financial_app/models/responses/dto_category.dart';

class DtoBudget {
  final String id;
  final String name;
  final double amount;
  final String period;
  final int month;
  final int year;
  final DtoCategory category;

  DtoBudget({
    required this.id,
    required this.name,
    required this.amount,
    required this.period,
    required this.month,
    required this.year,
    required this.category,
  });

  factory DtoBudget.fromJson(Map<String, dynamic> json) {
    return DtoBudget(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      period: json['period'] as String,
      month: json['month'] as int,
      year: json['year'] as int,
      category: DtoCategory.fromJson(json['category'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'period': period,
      'month': month,
      'year': year,
      'category': category.toJson(),
    };
  }
}
