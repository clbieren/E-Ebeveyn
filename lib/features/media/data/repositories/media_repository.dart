import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/sound_track_model.dart';

final class MediaRepository {
  const MediaRepository(this._client);

  final SupabaseClient _client;

  /// Tüm ses dosyalarını Supabase'den çeker.
  /// Kategori sütununa göre gruplandırma provider katmanında yapılır.
  Future<List<SoundTrackModel>> getTracks() async {
    final response = await _client
        .from('kids_media')
        .select()
        .order('category', ascending: true)
        .order('title', ascending: true);

    return (response as List)
        .map((e) => SoundTrackModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Belirli kategorideki parçaları getirir.
  Future<List<SoundTrackModel>> getTracksByCategory(String category) async {
    final response = await _client
        .from('kids_media')
        .select()
        .eq('category', category)
        .order('title', ascending: true);

    return (response as List)
        .map((e) => SoundTrackModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
