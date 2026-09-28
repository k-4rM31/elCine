import 'package:dio/dio.dart';
import 'token_storage.dart';

/// Fonction qui échange un refresh token contre une nouvelle paire de tokens.
/// Retourne null si le refresh échoue (token expiré, révoqué...).
typedef RefreshTokenCallback = Future<AuthTokens?> Function(
  String refreshToken,
);

/// Intercepteur qui :
/// 1) injecte automatiquement le token dans chaque requête sortante,
/// 2) tente un refresh puis rejoue la requête quand le serveur répond 401.
///
/// QueuedInterceptor : traite les requêtes UNE PAR UNE. Si 5 requêtes
/// reçoivent un 401 en même temps, un seul refresh est lancé, pas cinq.
class AuthInterceptor extends QueuedInterceptor {
  final TokenStorage tokenStorage;

  /// Dio "propre" (sans intercepteurs) utilisé pour rejouer les requêtes.
  /// Utiliser le Dio principal provoquerait un deadlock (voir explications).
  final Dio retryDio;

  final RefreshTokenCallback onRefresh;

  /// Appelé quand la session est définitivement perdue
  /// (ex: pour rediriger l'utilisateur vers l'écran de connexion).
  final void Function()? onSessionExpired;

  AuthInterceptor({
    required this.tokenStorage,
    required this.retryDio,
    required this.onRefresh,
    this.onSessionExpired,
  });

  // Clé utilisée dans options.extra pour marquer une requête déjà rejouée
  static const _retriedKey = 'retried';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStorage.getAccessToken();

    // Si l'utilisateur est connecté, on ajoute le header Authorization
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // On laisse TOUJOURS la requête continuer (connecté ou non)
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final alreadyRetried = err.requestOptions.extra[_retriedKey] == true;

    // Autre erreur qu'un 401, ou déjà rejoué : on ne touche à rien
    if (!isUnauthorized || alreadyRetried) {
      return handler.next(err);
    }

    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken == null) {
      await _endSession();
      return handler.next(err);
    }

    try {
      final newTokens = await onRefresh(refreshToken);
      if (newTokens == null) {
        await _endSession();
        return handler.next(err);
      }

      // Refresh réussi : on sauvegarde la nouvelle paire
      await tokenStorage.saveTokens(newTokens);

      // On reprend la requête d'origine avec le nouveau token
      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer ${newTokens.accessToken}';
      options.extra[_retriedKey] = true;

      final response = await retryDio.fetch(options);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    } catch (_) {
      return handler.next(err);
    }
  }

  Future<void> _endSession() async {
    await tokenStorage.clear();
    onSessionExpired?.call();
  }
}