import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Erreur venant du serveur (ex: TMDb renvoie un code 500, 401, etc.)
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Erreur de connexion réseau (pas d'internet, timeout...)
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Erreur liée au cache local (Hive) ex: rien en cache
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Erreur d'authentification (identifiants invalides, token expiré et refresh échoué)
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Erreur générique/inattendue
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}