class DropdownAccount {
  final int id;
  final String name;
  final String color;

  DropdownAccount({required this.id, required this.name, required this.color});

  factory DropdownAccount.fromJson(Map<String, dynamic> json) {
    return DropdownAccount(
      id: json['id'] as int,
      name: json['name'] as String,
      color: json['color'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'color': color};
  }
}
