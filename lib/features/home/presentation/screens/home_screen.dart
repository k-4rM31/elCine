import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/media_item.dart';
import '../providers/home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('el Cine')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(trendingProvider);
          ref.invalidate(starterPicksProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            _Section(
              title: 'Tendance cette semaine',
              asyncEither: ref.watch(trendingProvider),
            ),
            const SizedBox(height: 24),
            _Section(
              title: 'Pour commencer',
              asyncEither: ref.watch(starterPicksProvider),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final AsyncValue<Either<dynamic, List<MediaItem>>> asyncEither;

  const _Section({required this.title, required this.asyncEither});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: asyncEither.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erreur: $e')),
            data: (either) => either.fold(
              (failure) => Center(child: Text(failure.message)),
              (items) => items.isEmpty
                  ? const Center(child: Text('Aucun contenu'))
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => _PosterCard(item: items[i]),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PosterCard extends StatelessWidget {
  final MediaItem item;
  const _PosterCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.posterPath != null
        ? '${ApiConstants.imageBaseUrl}/${ApiConstants.posterSizeW500}${item.posterPath}'
        : null;

    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl != null
                ? Image.network(imageUrl, height: 160, width: 140, fit: BoxFit.cover)
                : Container(
                    height: 160,
                    width: 140,
                    color: Colors.grey.shade800,
                    child: const Icon(Icons.movie),
                  ),
          ),
          const SizedBox(height: 4),
          Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('${item.year ?? '—'} · ⭐ ${item.voteAverage.toStringAsFixed(1)}'),
        ],
      ),
    );
  }
}