import 'package:flutter/material.dart';

import '../../data/models/sound_track_model.dart';

class TrackListTile extends StatelessWidget {
  const TrackListTile({
    required this.track,
    required this.isActive,
    required this.isPlaying,
    required this.onTapPlayPause,
    super.key,
  });

  final SoundTrackModel track;
  final bool isActive;
  final bool isPlaying;
  final VoidCallback onTapPlayPause;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final durationLabel =
        '${track.duration.inMinutes}:${(track.duration.inSeconds % 60).toString().padLeft(2, '0')}';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: cs.surfaceContainerHighest,
        child: Icon(track.iconData, color: cs.onSurface, size: 18),
      ),
      title: Text(
        track.title,
        style: TextStyle(
          color: isActive ? cs.primary : cs.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        durationLabel,
        style: TextStyle(color: cs.onSurfaceVariant),
      ),
      trailing: IconButton(
        icon: Icon(
          isActive && isPlaying
              ? Icons.pause_circle_filled
              : Icons.play_circle_fill,
          color: isActive ? cs.primary : cs.onSurfaceVariant,
          size: 30,
        ),
        onPressed: onTapPlayPause,
      ),
    );
  }
}
