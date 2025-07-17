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
}
