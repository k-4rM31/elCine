/// Toutes les constantes liées à l'API TMDb, centralisées ici.
class ApiConstants {
  // URL de base de l'API TMDb 
  static const String baseUrl = 'https://api.themoviedb.org/3';

  // URL de base pour construire les liens d'images (posters, backdrops)
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';

  // Tailles d'images disponibles chez TMDb (utile pour choisir la résolution)
  static const String posterSizeW500 = 'w500';
  static const String backdropSizeW780 = 'w780';

  // Clé API récupérée via --dart-define (JAMAIS en dur dans le code !)
  static const String apiKey = String.fromEnvironment('TMDB_API_KEY');

  // Timeouts réseau en millisecondes
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;

  // Endpoints TMDb utilisés dans l'app
  static const String trendingAllWeek = '/trending/all/week';
  static const String popularMovies = '/movie/popular';
  static const String searchMulti = '/search/multi';
  static const String movieDetail = '/movie'; // + /{id}
  static const String tvDetail = '/tv'; // + /{id}
}