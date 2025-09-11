class SaveCategory {
  final int? id;
  final String name;
  final String? description;
  final int? icon;
  final String? color;

  SaveCategory({
    this.id,
    required this.name,
    this.description,
    this.icon,
    this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
    };
  }

  factory SaveCategory.fromJson(Map<String, dynamic> json) {
    return SaveCategory(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as int?,
      color: json['color'] as String?,
    );
  }
}
