import 'package:dio/dio.dart';
import '../error/exception.dart';

/// Traduit une erreur technique de Dio en exception "maison".
/// Appelée dans les DATASOURCES (couche data), jamais dans le repository :
/// le repository, lui, ne connaît que nos exceptions, pas Dio.
Exception mapDioException(DioException e) {
  // Pas de `default:` volontairement : le compilateur vérifie que tous
  // les cas de l'enum sont traités.
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return const NetworkException(
        'La connexion a expiré. Vérifiez votre réseau et réessayez.',
      );

    case DioExceptionType.connectionError:
      return const NetworkException('Pas de connexion internet.');

    case DioExceptionType.badResponse:
      // Le serveur a répondu, mais avec un code d'erreur (4xx, 5xx)
      return _fromResponse(e.response);

    case DioExceptionType.cancel:
      return const ServerException('La requête a été annulée.');

    case DioExceptionType.badCertificate:
      return const ServerException('Certificat de sécurité invalide.');

    case DioExceptionType.unknown:
      return const ServerException('Une erreur inattendue est survenue.');
  }
}

/// Analyse la réponse d'erreur du serveur pour choisir la bonne exception.
Exception _fromResponse(Response? response) {
  final status = response?.statusCode;
  final data = response?.data;

  // TMDb renvoie ses erreurs sous la forme :
  // { "status_code": 7, "status_message": "Invalid API key..." }
  String? serverMessage;
  if (data is Map<String, dynamic>) {
    final message = data['status_message'];
    if (message is String) serverMessage = message;
  }

  switch (status) {
    case 401:
      return AuthException(serverMessage ?? 'Authentification requise.');
    case 404:
      return ServerException(serverMessage ?? 'Contenu introuvable.');
    case 429:
      return const ServerException(
        'Trop de requêtes. Patientez un instant avant de réessayer.',
      );
    default:
      return ServerException(serverMessage ?? 'Erreur serveur ($status).');
  }
}