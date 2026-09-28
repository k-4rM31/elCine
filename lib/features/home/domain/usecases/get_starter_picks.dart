import 'package:fpdart/fpdart.dart';
import 'package:el_cine/core/error/failures.dart';
import 'package:el_cine/core/usecase/usecase.dart';
import '../entities/media_item.dart';
import '../repositories/home_repository.dart';

/// Action métier : « récupérer la sélection "Pour commencer" ».
class GetStarterPicks implements UseCase<List<MediaItem>, NoParams> {
  final HomeRepository repository;

  const GetStarterPicks(this.repository);

  @override
  Future<Either<Failure, List<MediaItem>>> call(NoParams params) {
    return repository.getStarterPicks();
  }
}