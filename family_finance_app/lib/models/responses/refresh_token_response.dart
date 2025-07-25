class RefreshTokenResponse {
  final String? accessToken;
  final String? refreshToken;
  final DateTime? expiration;

  RefreshTokenResponse({
    this.accessToken,
    this.refreshToken,
    this.expiration,
  });
}
