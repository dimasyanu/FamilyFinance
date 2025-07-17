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
}
