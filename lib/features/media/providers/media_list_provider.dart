import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/sound_track_model.dart';
import '../data/repositories/media_repository.dart';

/// Repository provider — Supabase client'ı inject eder.
final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  return MediaRepository(Supabase.instance.client);
});

/// Tüm parçaları tek liste olarak getirir.
final mediaTracksProvider = FutureProvider<List<SoundTrackModel>>((ref) async {
  return ref.watch(mediaRepositoryProvider).getTracks();
});

/// Kategori bazlı gruplandırılmış parçalar.
final categorizedMediaTracksProvider =
    FutureProvider<Map<String, List<SoundTrackModel>>>((ref) async {
  final tracks = await ref.watch(mediaTracksProvider.future);
  final grouped = <String, List<SoundTrackModel>>{};

  for (final track in tracks) {
    grouped.putIfAbsent(track.category, () => <SoundTrackModel>[]).add(track);
  }

  return grouped;
});
