import 'package:el_cine/core/error/exception.dart';
import 'package:el_cine/core/error/failures.dart';
import 'package:el_cine/core/network/network_info.dart';
import 'package:el_cine/features/home/data/datasources/home_local_datasource.dart';
import 'package:el_cine/features/home/data/datasources/home_remote_datasource.dart';
import 'package:el_cine/features/home/data/repositories/home_repository_impl.dart';
import 'package:el_cine/features/home/data/models/media_item_model.dart';
import 'package:el_cine/features/home/domain/entities/media_type.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Classes "fake" qui imitent les vraies grâce à mocktail
class MockRemoteDataSource extends Mock implements HomeRemoteDataSource {}
class MockLocalDataSource extends Mock implements HomeLocalDataSource {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late HomeRepositoryImpl repository;
  late MockRemoteDataSource mockRemote;
  late MockLocalDataSource mockLocal;
  late MockNetworkInfo mockNetworkInfo;

  // Recréé avant CHAQUE test, pour que les tests soient indépendants
  // les uns des autres (aucun état partagé entre eux).
  setUp(() {
    mockRemote = MockRemoteDataSource();
    mockLocal = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = HomeRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
      networkInfo: mockNetworkInfo,
    );
  });

  // Donnée de test réutilisée dans plusieurs tests
  final tMediaItem = MediaItemModel(
    id: 1,
    title: 'Inception',
    mediaType: MediaType.movie,
    overview: 'Un voleur qui s\'infiltre dans les rêves...',
    voteAverage: 8.3,
  );
  final tMediaItemList = [tMediaItem];

  group('getTrendingThisWeek', () {
    test(
      '1) doit sauvegarder les données en cache quand l\'API répond avec succès',
      () async {
        // ARRANGE : on configure le comportement des mocks
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemote.getTrendingThisWeek())
            .thenAnswer((_) async => tMediaItemList);
        when(() => mockLocal.cacheTrending(any()))
            .thenAnswer((_) async => Future.value());

        // ACT : on appelle la méthode testée
        await repository.getTrendingThisWeek();

        // ASSERT : on vérifie que le cache a bien été appelé avec la donnée
        verify(() => mockLocal.cacheTrending(tMediaItemList)).called(1);
      },
    );

    test(
      '3) doit retourner les données du cache quand le réseau est indisponible',
      () async {
        // ARRANGE
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        when(() => mockLocal.getCachedTrending())
            .thenAnswer((_) async => tMediaItemList);

        // ACT
        final result = await repository.getTrendingThisWeek();

        // ASSERT
        verifyNever(() => mockRemote.getTrendingThisWeek()); // API jamais appelée
        verify(() => mockLocal.getCachedTrending()).called(1);
        expect(result, Right(tMediaItemList));
      },
    );

    test(
      'doit retourner CacheFailure si hors ligne ET rien en cache',
      () async {
        // ARRANGE
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        when(() => mockLocal.getCachedTrending())
            .thenThrow(const CacheException('Rien en cache'));

        // ACT
        final result = await repository.getTrendingThisWeek();

        // ASSERT
        expect(result, isA<Left<Failure, dynamic>>());
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (_) => fail('Aurait dû retourner un Left'),
        );
      },
    );
  });

  group('getStarterPicks (recherche)', () {
    test(
      '2) doit transmettre correctement l\'appel au datasource distant',
      () async {
        // ARRANGE
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemote.getStarterPicks())
            .thenAnswer((_) async => tMediaItemList);
        when(() => mockLocal.cacheStarterPicks(any()))
            .thenAnswer((_) async => Future.value());

        // ACT
        await repository.getStarterPicks();

        // ASSERT : on vérifie que le repository a bien appelé le remote
        // datasource, sans transformation ni altération
        verify(() => mockRemote.getStarterPicks()).called(1);
      },
    );
  });
}