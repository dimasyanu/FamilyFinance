class ItemCategory {
  final String id;
  final String name;
  final String? description;
  final String? color;
  final DateTime createdAt;
  final String createdBy;

  ItemCategory({
    required this.id,
    required this.name,
    this.description,
    this.color,
    required this.createdAt,
    required this.createdBy,
  });
}