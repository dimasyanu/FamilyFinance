class SaveCategory {
  final String? id;
  final String name;
  final String? description;
  final String? color;

  SaveCategory({this.id, required this.name, this.description, this.color});

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description, 'color': color};
  }

  factory SaveCategory.fromJson(Map<String, dynamic> json) {
    return SaveCategory(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      color: json['color'] as String?,
    );
  }
}
