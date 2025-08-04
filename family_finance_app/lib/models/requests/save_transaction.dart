class SaveTransaction {
  String? id;
  String? description;
  final double amount;
  final int transactionType; // -1 for expense, 1 for income, 0 for other
  final DateTime transactionDate;
  final String? categoryId;
  final String accountId;

  SaveTransaction({
    this.id,
    this.description,
    required this.amount,
    required this.transactionType,
    required this.transactionDate,
    this.categoryId,
    required this.accountId,
  });
}
