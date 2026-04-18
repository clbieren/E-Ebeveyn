import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/vaccination_repository.dart';

final vaccinationRepositoryProvider = Provider<VaccinationRepository>((ref) {
  return VaccinationRepository(Supabase.instance.client);
});

final completedVaccineKeysProvider =
    FutureProvider.family<Set<String>, String>((ref, childSyncId) async {
  return ref.watch(vaccinationRepositoryProvider).fetchCompletedKeys(
        childSyncId,
      );
});
