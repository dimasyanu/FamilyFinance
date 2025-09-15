import 'package:family_financial_app/abstractions/serializable.dart';

class DtoUser extends Serializable {
  final int id;
  final String name;
  final String username;

  DtoUser({required this.id, required this.name, required this.username});

  factory DtoUser.fromJson(Map<String, dynamic> json) {
    return DtoUser(
      id: json['id'],
      name: json['name'],
      username: json['username'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'username': username};
  }
}
