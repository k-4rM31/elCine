import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../constants/api_constants.dart';
import '../network/dio_client.dart';
import '../network/hive_boxes.dart';
import '../network/network_info.dart';

import '../../features/home/data/datasources/home_local_datasource.dart';
import '../../features/home/data/datasources/home_remote_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_starter_picks.dart';
import '../../features/home/domain/usecases/get_trending_this_week.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // --- Core ---
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(Connectivity()),
  );

  // Client Dio dédié à TMDb (api_key, pas d'AuthInterceptor)
  final tmdbDio = DioClient(
    queryParameters: {'api_key': ApiConstants.apiKey},
  ).dio;
  getIt.registerLazySingleton<Dio>(() => tmdbDio, instanceName: 'tmdbDio');

  // Box Hive ouverte dans main.dart, on la récupère ici
  getIt.registerLazySingleton<Box>(() => Hive.box(HiveBoxes.home));

  // --- Feature: home ---
  getIt.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(getIt<Dio>(instanceName: 'tmdbDio')),
  );
  getIt.registerLazySingleton<HomeLocalDataSource>(
    () => HomeLocalDataSourceImpl(getIt<Box>()),
  );
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
      remoteDataSource: getIt<HomeRemoteDataSource>(),
      localDataSource: getIt<HomeLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );
  getIt.registerLazySingleton(() => GetTrendingThisWeek(getIt<HomeRepository>()));
  getIt.registerLazySingleton(() => GetStarterPicks(getIt<HomeRepository>()));
}