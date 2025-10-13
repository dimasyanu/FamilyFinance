class SaveAccount {
  int? id;
  String name;
  String? description;
  String? color;

  SaveAccount({this.id, required this.name, this.description, this.color});

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description, 'color': color};
  }
}
