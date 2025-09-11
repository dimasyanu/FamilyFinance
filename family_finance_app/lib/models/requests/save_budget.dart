class SaveBudget {
  int? id;
  final int categoryId;
  final int month;
  final int year;
  final double amount;

  SaveBudget({
    this.id,
    required this.categoryId,
    required this.month,
    required this.year,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'month': month,
      'year': year,
      'amount': amount,
    };
  }

  factory SaveBudget.fromJson(Map<String, dynamic> json) {
    return SaveBudget(
      id: json['id'] as int?,
      categoryId: json['categoryId'] as int,
      month: json['month'] as int,
      year: json['year'] as int,
      amount: (json['amount'] as num).toDouble(),
    );
  }
}
