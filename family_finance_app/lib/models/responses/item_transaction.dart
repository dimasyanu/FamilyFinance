class ItemTransaction {
  final String id;
  final String description;
  final double amount;
  final String transactionDate;
  final String transactionTime;
  final int transactionType;
  final String category;
  final int categoryIcon;
  final String categoryColor;
  final String account;
  final String accountColor;
  final String? notes;

  ItemTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.transactionDate,
    required this.transactionTime,
    required this.transactionType,
    required this.category,
    required this.categoryIcon,
    required this.categoryColor,
    required this.account,
    required this.accountColor,
    this.notes,
  });

  factory ItemTransaction.fromJson(Map<String, dynamic> json) {
    return ItemTransaction(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      transactionDate: json['transactionDate'] as String,
      transactionTime: json['transactionTime'] as String,
      transactionType: json['transactionType'] as int,
      category: json['category'] as String,
      categoryIcon: json['categoryIcon'] as int,
      categoryColor: json['categoryColor'] as String,
      account: json['account'] as String,
      accountColor: json['accountColor'] as String,
      notes: json['notes'] as String?,
    );
  }
}
