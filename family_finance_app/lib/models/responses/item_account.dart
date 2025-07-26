class ItemAccount {
  final String id;
  final String name;
  final String? description;
  final String color;
  final double balance;
  final String createdAt;
  final String createdBy;
  final String? updatedAt;
  final String? updatedBy;
  final bool isActive;

  ItemAccount({
    required this.id,
    required this.name,
    required this.color,
    this.description,
    required this.balance,
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.isActive = true,
  });

  factory ItemAccount.fromJson(Map<String, dynamic> json) {
    try {
    return ItemAccount(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] ?? '#000',
      description: json['description'] as String?,
      balance: (json['balance'] as num).toDouble(),
      createdAt: json['createdAt'],
      createdBy: json['createdBy'] as String,
      updatedAt: json['updatedAt'] ?? '',
      updatedBy: json['updatedBy'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
    } catch (e) {
      throw FormatException('Error parsing ItemAccount: $e', json);
    }
  }
}
