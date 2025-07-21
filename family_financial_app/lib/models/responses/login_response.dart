class LoginResponse {
  final String username;
  final String accessToken;
  final String refreshToken;
  final DateTime expiration;

  LoginResponse({
    required this.username,
    required this.accessToken,
    required this.refreshToken,
    required this.expiration,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      username: json['username'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      expiration: DateTime.parse(json['expiration']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiration': expiration.toIso8601String(),
    };
  }
}
