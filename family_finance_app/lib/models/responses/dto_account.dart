class DtoAccount {
  final int? id;
  final String? name;
  final String? description;
  final String? color;

  DtoAccount({this.id, this.name, this.description, this.color});

  factory DtoAccount.fromJson(Map<String, dynamic> json) {
    return DtoAccount(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      color: json['color'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description, 'color': color};
  }
}
