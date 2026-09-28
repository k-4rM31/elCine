class AuthTokens {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({ required this.accessToken, required this.refreshToken });
}

abstract class TokenStorage {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveTokens(AuthTokens tokens);
  Future<void> clear();
}