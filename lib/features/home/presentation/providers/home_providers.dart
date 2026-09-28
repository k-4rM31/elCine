import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/usecases/get_starter_picks.dart';
import '../../domain/usecases/get_trending_this_week.dart';

final trendingProvider =
    FutureProvider.autoDispose<Either<Failure, List<MediaItem>>>((ref) {
  final usecase = getIt<GetTrendingThisWeek>();
  return usecase(NoParams());
});

final starterPicksProvider =
    FutureProvider.autoDispose<Either<Failure, List<MediaItem>>>((ref) {
  final usecase = getIt<GetStarterPicks>();
  return usecase(NoParams());
});