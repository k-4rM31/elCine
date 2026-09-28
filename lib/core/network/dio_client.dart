import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

/// Fabrique une instance Dio configurée.
/// Cette classe ne sait rien de TMDb ni du backend : elle est réutilisable
/// pour n'importe quelle API, c'est l'appelant qui la paramètre.
class DioClient {
  final Dio dio;

  DioClient({
    // URL de base : TMDb par défaut, mais on pourra passer celle du backend
    String baseUrl = ApiConstants.baseUrl,

    // Paramètres ajoutés à CHAQUE requête (ex: api_key pour TMDb)
    Map<String, dynamic>? queryParameters,

    // Intercepteurs à brancher (ex: AuthInterceptor pour le backend)
    List<Interceptor> interceptors = const [],
  }) : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(
              milliseconds: ApiConstants.connectTimeout,
            ),
            receiveTimeout: const Duration(
              milliseconds: ApiConstants.receiveTimeout,
            ),
            queryParameters: queryParameters ?? {},
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    // Le corps du constructeur s'exécute une fois `dio` créé :
    // c'est le bon endroit pour brancher les intercepteurs.
    dio.interceptors.addAll(interceptors);
  }
}