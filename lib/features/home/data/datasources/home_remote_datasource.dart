import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_error_handler.dart';
import '../../domain/entities/media_type.dart';
import '../models/media_item_model.dart';

/// Contrat abstrait : PERMET de mocker facilement dans les tests
/// du repository, sans jamais instancier un vrai Dio.
abstract class HomeRemoteDataSource {
  Future<List<MediaItemModel>> getTrendingThisWeek();
  Future<List<MediaItemModel>> getStarterPicks();
}

/// Implémentation réelle : parle à TMDb via Dio.
/// Ne connaît QUE Dio et le JSON — aucune idée de ce qu'est Hive,
/// et aucune idée d'Either/Failure (ça, c'est le rôle du repository).
class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;

  const HomeRemoteDataSourceImpl(this.dio);

  @override
  Future<List<MediaItemModel>> getTrendingThisWeek() async {
    try {
      final response = await dio.get(ApiConstants.trendingAllWeek);

      final results = response.data['results'] as List;

      // media_type est déjà fourni par cet endpoint, pas besoin de fallback
      return results
          .map((item) => MediaItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // Traduction Dio -> nos exceptions maison (voir étape 5.4)
      throw mapDioException(e);
    }
  }

  @override
  Future<List<MediaItemModel>> getStarterPicks() async {
    try {
      final response = await dio.get(ApiConstants.popularMovies);

      final results = response.data['results'] as List;

      // Cet endpoint ne renvoie QUE des films : media_type est absent
      // du JSON, donc on le précise nous-mêmes.
      return results
          .map((item) => MediaItemModel.fromJson(
                item as Map<String, dynamic>,
                fallbackMediaType: MediaType.movie,
              ))
          .toList();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}