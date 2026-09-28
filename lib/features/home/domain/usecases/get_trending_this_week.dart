import 'package:fpdart/fpdart.dart';
import 'package:el_cine/core/error/failures.dart';
import 'package:el_cine/core/usecase/usecase.dart';
import 'package:el_cine/features/home/domain/entities/media_item.dart';
import '../repositories/home_repository.dart';

/// Action métier : « récupérer les tendances de la semaine ».
class GetTrendingThisWeek implements UseCase<List<MediaItem>, NoParams> {
  final HomeRepository repository;

  const GetTrendingThisWeek(this.repository);

  @override
  Future<Either<Failure, List<MediaItem>>> call(NoParams params) {
    return repository.getTrendingThisWeek();
  }
}