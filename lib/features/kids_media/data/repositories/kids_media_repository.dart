import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kids_media_model.dart';

class KidsMediaRepository {
  final SupabaseClient _client;

  KidsMediaRepository(this._client);

  Future<List<KidsMediaModel>> getMediaByCategory(String category) async {
    // Supabase'den veriyi çeker, oluşturulma tarihine göre (en yeni üstte) sıralar
    final response = await _client
        .from('kids_media')
        .select()
        .eq('category', category)
        .order('created_at', ascending: false);

    return (response as List).map((e) => KidsMediaModel.fromJson(e)).toList();
  }
}
