import 'package:equatable/equatable.dart';
import './media_type.dart';

class MediaItem extends Equatable {
  final int id;
  final String title;
  final MediaType mediaType;
  final String overview;
  final double voteAverage;
  final String? posterPath;
  final String? backdropPath;
  final DateTime? releaseDate;

  const MediaItem({
    required this.id,
    required this.title,
    required this.mediaType,
    required this.overview,
    required this.voteAverage,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
  });

  /// Année de sortie à afficher null si la releaseDate est inconnue.
  String? get year => releaseDate?.year.toString();

  @override
  List<Object?> get props => [
    id,
    title,
    mediaType,
    overview,
    voteAverage,
    posterPath,
    backdropPath,
    releaseDate,
  ];
}