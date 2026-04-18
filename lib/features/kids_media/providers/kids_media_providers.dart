import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/kids_media_model.dart';
import '../data/repositories/kids_media_repository.dart';

part 'kids_media_providers.g.dart';

@Riverpod(keepAlive: true)
KidsMediaRepository kidsMediaRepository(Ref ref) {
  return KidsMediaRepository(Supabase.instance.client);
}

@riverpod
Future<List<KidsMediaModel>> ninnilerList(Ref ref) {
  return ref.watch(kidsMediaRepositoryProvider).getMediaByCategory('NİNNİ');
}

@riverpod
Future<List<KidsMediaModel>> hikayelerList(Ref ref) {
  return ref.watch(kidsMediaRepositoryProvider).getMediaByCategory('HİKAYE');
}
