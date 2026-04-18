import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/audio_player_provider.dart';

class PersistentMiniPlayer extends ConsumerWidget {
  const PersistentMiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final playerState = ref.watch(audioPlayerProvider);
    final track = playerState.currentTrack;
    if (track == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(track.iconData, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              track.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              playerState.isPlaying
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              color: cs.onSurface,
            ),
            onPressed: () {
              final controller = ref.read(audioPlayerProvider.notifier);
              if (playerState.isPlaying) {
                controller.pause();
              } else {
                controller.playTrack(track);
              }
            },
          ),
          PopupMenuButton<Duration>(
            icon: Icon(Icons.timer_outlined, color: cs.onSurfaceVariant),
            color: cs.surfaceContainerHighest,
            onSelected: (duration) {
              final controller = ref.read(audioPlayerProvider.notifier);
              if (duration == Duration.zero) {
                controller.clearSleepTimer();
              } else {
                controller.setSleepTimer(duration);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: Duration(minutes: 15),
                child: Text('15 dk'),
              ),
              PopupMenuItem(
                value: Duration(minutes: 30),
                child: Text('30 dk'),
              ),
              PopupMenuItem(
                value: Duration(minutes: 60),
                child: Text('60 dk'),
              ),
              PopupMenuItem(
                value: Duration.zero,
                child: Text('Zamanlayiciyi Kapat'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
