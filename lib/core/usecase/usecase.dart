import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../error/failures.dart';

/// Contrat générique que TOUS les usecases de l'app doivent respecter.

/// [TypeData] ce que le usecase retourne en cas de succès (ex: List&ltMovie&gt)
/// [Params] les paramètres dont il a besoin en entrée (ex: un id, une query)
abstract class UseCase<TypeData, Params> {
  Future<Either<Failure, TypeData>> call(Params params);
}

/// Classe utilitaire pour les usecases qui n'ont besoin d'AUCUN paramètre.
/// Exemple : GetTrendingMovies n'a pas besoin d'arguments.
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}