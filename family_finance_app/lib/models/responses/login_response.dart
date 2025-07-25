import 'package:family_financial_app/abstractions/serializable.dart';

class LoginResponse extends Serializable {
  final String username;
  final String userId;
  final String accessToken;
  final String refreshToken;
  final DateTime expiration;

  LoginResponse({
    required this.username,
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.expiration,
  });

  @override
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      username: json['username'] as String,
      userId: json['userId'] as String,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiration: DateTime.parse(json['expiration']).toLocal(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'userId': userId,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiration': expiration.toIso8601String(),
    };
  }
}
