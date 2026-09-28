import 'package:el_cine/core/error/exception.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import 'package:fpdart/fpdart.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  const HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<MediaItem>>> getTrendingThisWeek() async {
    if (await networkInfo.isConnected) {
      try {
        final items = await remoteDataSource.getTrendingThisWeek();
        await localDataSource.cacheTrending(items);
        return Right(items);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(UnexpectedFailure(e.toString()));
      }
    } else {
      try {
        final cached = await localDataSource.getCachedTrending();
        return Right(cached);
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<MediaItem>>> getStarterPicks() async {
    if (await networkInfo.isConnected) {
      try {
        final items = await remoteDataSource.getStarterPicks();
        await localDataSource.cacheStarterPicks(items);
        return Right(items);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(UnexpectedFailure(e.toString()));
      }
    } else {
      try {
        final cached = await localDataSource.getCachedStarterPicks();
        return Right(cached);
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }
}