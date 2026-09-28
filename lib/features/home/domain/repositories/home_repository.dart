import 'package:fpdart/fpdart.dart';
import 'package:el_cine/core/error/failures.dart';
import '../entities/media_item.dart';

/// CONTRAT de la feature home : il décrit CE QU'ON PEUT FAIRE,
/// pas COMMENT c'est fait. L'implémentation (API + cache) vit dans `data`.
abstract class HomeRepository {
  /// Films et séries tendance de la semaine (section « Tendance cette semaine »).
  Future<Either<Failure, List<MediaItem>>> getTrendingThisWeek();

  /// Sélection populaire (section « Pour commencer »).
  Future<Either<Failure, List<MediaItem>>> getStarterPicks();
}