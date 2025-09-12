class ItemCategory {
  final int id;
  final String name;
  final String? description;
  final String color;
  final int icon;
  final String createdAt;
  final int createdBy;

  ItemCategory({
    required this.id,
    required this.name,
    this.description,
    required this.color,
    required this.icon,
    required this.createdAt,
    required this.createdBy,
  });

  factory ItemCategory.fromJson(Map<String, dynamic> json) {
    return ItemCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      color: json['color'] as String,
      icon: json['icon'] as int,
      createdAt: json['createdAt'] as String,
      createdBy: json['createdBy'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'icon': icon,
      'createdAt': createdAt,
      'createdBy': createdBy,
    };
  }
}
