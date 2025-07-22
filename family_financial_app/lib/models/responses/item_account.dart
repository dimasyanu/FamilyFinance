class ItemAccount {
  final String id;
  final String name;
  final String? description;
  final double balance;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;
  final bool isActive;

  ItemAccount({
    required this.id,
    required this.name,
    this.description,
    required this.balance,
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.isActive = true,
  });

  factory ItemAccount.fromJson(Map<String, dynamic> json) {
    return ItemAccount(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      balance: (json['balance'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      updatedBy: json['updatedBy'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
