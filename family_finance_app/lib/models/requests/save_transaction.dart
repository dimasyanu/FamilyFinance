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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'transactionType': transactionType,
      'transactionDate': transactionDate.toIso8601String(),
      'categoryId': categoryId,
      'accountId': accountId,
    };
  }

  factory SaveTransaction.fromJson(Map<String, dynamic> json) {
    return SaveTransaction(
      id: json['id'] as String?,
      description: json['description'] as String?,
      amount: (json['amount'] as num).toDouble(),
      transactionType: json['transactionType'] as int,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      categoryId: json['categoryId'] as String?,
      accountId: json['accountId'] as String,
    );
  }
}
