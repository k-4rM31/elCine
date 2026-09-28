/// Exceptions techniques lancées dans la couche DATA
/// (datasources : Dio, Hive). Elles sont ATTRAPÉES par le repository
/// et converties en Failure avant de remonter au domain.
class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Erreur serveur']);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Pas de connexion internet']);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Aucune donnée en cache']);
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Échec d\'authentification']);
}