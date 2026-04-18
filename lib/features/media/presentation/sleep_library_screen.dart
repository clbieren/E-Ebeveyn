import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/widgets/shimmer_skeleton.dart';
import '../providers/audio_player_provider.dart';
import '../providers/media_list_provider.dart';
import 'widgets/category_header.dart';
import 'widgets/persistent_mini_player.dart';
import 'widgets/track_list_tile.dart';

class SleepLibraryScreen extends ConsumerWidget {
  const SleepLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tracksAsync = ref.watch(categorizedMediaTracksProvider);
    final playerState = ref.watch(audioPlayerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Uyku Kütüphanesi',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w800),
        ),
      ),
      body: tracksAsync.when(
        loading: () => const _SleepLibrarySkeleton(),
        error: (_, __) => Center(
          child: Text(
            'Ses kütüphanesi yüklenemedi',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
        data: (grouped) {
          final categories = grouped.keys.toList();
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 92),
            itemCount: categories.length,
            itemBuilder: (context, categoryIndex) {
              final category = categories[categoryIndex];
              final tracks = grouped[category] ?? const [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CategoryHeader(title: category),
                  ...tracks.map((track) {
                    final isActive = playerState.currentTrack?.id == track.id;
                    return TrackListTile(
                      track: track,
                      isActive: isActive,
                      isPlaying: playerState.isPlaying,
                      onTapPlayPause: () {
                        final controller =
                            ref.read(audioPlayerProvider.notifier);
                        if (isActive && playerState.isPlaying) {
                          controller.pause();
                        } else {
                          controller.playTrack(track);
                        }
                      },
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: const SafeArea(
        child: PersistentMiniPlayer(),
      ),
    );
  }
}

class _SleepLibrarySkeleton extends StatelessWidget {
  const _SleepLibrarySkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 92),
      itemCount: 10,
      itemBuilder: (_, index) {
        final isHeader = index % 4 == 0;
        if (isHeader) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(16, 18, 16, 10),
            child: ShimmerSkeleton(height: 12, width: 140),
          );
        }
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ShimmerSkeleton(
              height: 56, borderRadius: BorderRadius.all(Radius.circular(14))),
        );
      },
    );
  }
}
