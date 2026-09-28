enum MediaType {
  movie,
  tv,
  person;

  String get label {
    switch (this) {
      case MediaType.movie:
        return 'Film';
      case MediaType.tv:
        return 'Série';
      case MediaType.person:
        return 'Personne';
    }
  }

  /// Convertit la valeur brute de TMDb ('movie', 'tv', 'person').
  /// Valeur inconnue ou absente : on retombe sur `movie` plutôt que de planter.
  static MediaType fromString(String? value) {
    switch (value) {
      case 'tv':
        return MediaType.tv;
      case 'person':
        return MediaType.person;
      case 'movie':
      default:
        return MediaType.movie;
    }
  }
}