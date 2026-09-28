import 'package:el_cine/features/home/domain/entities/media_item.dart';
import 'package:el_cine/features/home/domain/entities/media_type.dart';

/// Pont entre le JSON (TMDb ou cache local) et l'entité MediaItem.
/// C'est le SEUL endroit de l'app qui sait lire du JSON pour ce type de
/// donnée. Le domain n'en a jamais entendu parler.
class MediaItemModel extends MediaItem {
  const MediaItemModel({
    required super.id,
    required super.title,
    required super.mediaType,
    required super.overview,
    required super.voteAverage,
    super.posterPath,
    super.backdropPath,
    super.releaseDate,
  });

  /// Construit un MediaItemModel depuis une réponse TMDb.
  ///
  /// [fallbackMediaType] : certains endpoints (ex: /movie/popular) ne
  /// renvoient pas le champ `media_type`. On le précise alors nous-mêmes,
  /// puisqu'on sait déjà, vu l'endpoint appelé, qu'il s'agit d'un film.
  factory MediaItemModel.fromJson(
    Map<String, dynamic> json, {
    MediaType? fallbackMediaType,
  }) {
    return MediaItemModel(
      id: json['id'] as int,
      title: (json['title'] as String?) ?? (json['name'] as String?) ?? '',
      mediaType: json['media_type'] != null
          ? MediaType.fromString(json['media_type'] as String?)
          : (fallbackMediaType ?? MediaType.movie),
      overview: (json['overview'] as String?) ?? '',
      voteAverage: ((json['vote_average'] as num?) ?? 0).toDouble(),
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: _parseDate(
        (json['release_date'] as String?) ??
            (json['first_air_date'] as String?),
      ),
    );
  }

  /// Reconstruit un MediaItemModel depuis NOTRE format de cache
  /// (celui produit par toJson ci-dessous). Différent de fromJson
  /// car le cache n'a pas les mêmes noms de champs que TMDb.
  factory MediaItemModel.fromCachedJson(Map<String, dynamic> json) {
    return MediaItemModel(
      id: json['id'] as int,
      title: json['title'] as String,
      mediaType: MediaType.fromString(json['mediaType'] as String?),
      overview: json['overview'] as String,
      voteAverage: (json['voteAverage'] as num).toDouble(),
      posterPath: json['posterPath'] as String?,
      backdropPath: json['backdropPath'] as String?,
      releaseDate: _parseDate(json['releaseDate'] as String?),
    );
  }

  /// Format utilisé pour SAUVEGARDER dans le cache local (Hive).
  /// Volontairement simple et stable : peu importe que TMDb change
  /// ses noms de champs demain, notre cache garde son propre format.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'mediaType': mediaType.name, // 'movie' / 'tv' / 'person'
      'overview': overview,
      'voteAverage': voteAverage,
      'posterPath': posterPath,
      'backdropPath': backdropPath,
      'releaseDate': releaseDate?.toIso8601String(),
    };
  }

  /// Parse une date de façon sûre : jamais d'exception, même si la
  /// chaîne est vide, mal formée ou absente.
  static DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}