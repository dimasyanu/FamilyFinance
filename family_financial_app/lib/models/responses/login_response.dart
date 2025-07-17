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
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      expiration: DateTime.parse(json['expiration']),
    );
  }
}
