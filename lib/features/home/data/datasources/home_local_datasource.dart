import 'dart:convert';
import 'package:el_cine/core/error/exception.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/media_item_model.dart';

abstract class HomeLocalDataSource {
  Future<List<MediaItemModel>> getCachedTrending();
  Future<void> cacheTrending(List<MediaItemModel> items);

  Future<List<MediaItemModel>> getCachedStarterPicks();
  Future<void> cacheStarterPicks(List<MediaItemModel> items);
}

/// Stocke les listes sous forme de JSON encodé en String, dans une
/// box Hive générique. Simple, pas besoin de TypeAdapter généré.
class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  final Box box;

  const HomeLocalDataSourceImpl(this.box);

  static const String _trendingKey = 'cached_trending';
  static const String _starterPicksKey = 'cached_starter_picks';

  @override
  Future<void> cacheTrending(List<MediaItemModel> items) async {
    final jsonList = items.map((item) => item.toJson()).toList();
    await box.put(_trendingKey, jsonEncode(jsonList));
  }

  @override
  Future<List<MediaItemModel>> getCachedTrending() async {
    final raw = box.get(_trendingKey) as String?;

    // Rien en cache : on le signale explicitement, on ne renvoie
    // JAMAIS une liste vide en silence (ton cahier des charges l'exige).
    if (raw == null) {
      throw const CacheException('Aucune donnée en cache pour les tendances.');
    }

    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((json) => MediaItemModel.fromCachedJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheStarterPicks(List<MediaItemModel> items) async {
    final jsonList = items.map((item) => item.toJson()).toList();
    await box.put(_starterPicksKey, jsonEncode(jsonList));
  }

  @override
  Future<List<MediaItemModel>> getCachedStarterPicks() async {
    final raw = box.get(_starterPicksKey) as String?;

    if (raw == null) {
      throw const CacheException('Aucune sélection en cache.');
    }

    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((json) => MediaItemModel.fromCachedJson(json as Map<String, dynamic>))
        .toList();
  }
}