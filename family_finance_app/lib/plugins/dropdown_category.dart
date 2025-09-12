class DropdownCategory {
  final int id;
  final String name;
  final String? description;
  final String color;
  final int icon;

  DropdownCategory({
    required this.id,
    required this.name,
    this.description,
    required this.color,
    required this.icon,
  });

  factory DropdownCategory.fromJson(Map<String, dynamic> json) {
    return DropdownCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      color: json['color'] as String,
      icon: json['icon'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'icon': icon,
    };
  }
}
