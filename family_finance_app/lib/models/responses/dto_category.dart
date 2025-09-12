class DtoCategory {
  final int? id;
  final String? name;
  final String? description;
  final int? icon;
  final String? color;

  DtoCategory({this.id, this.name, this.description, this.icon, this.color});

  factory DtoCategory.fromJson(Map<String, dynamic> json) {
    return DtoCategory(
      id: json['id'] as int,
      name: json['name'] as String?,
      description: json['description'] as String?,
      color: json['color'] as String?,
      icon: json['icon'] != null ? int.tryParse(json['icon'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
    };
  }
}
