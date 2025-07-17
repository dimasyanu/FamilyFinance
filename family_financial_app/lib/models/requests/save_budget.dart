class SaveBudget {
  String? id;
  final String categoryId;
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
}
