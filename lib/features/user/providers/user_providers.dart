import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/db/providers/realm_provider.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/repositories/user_local_repository.dart';

// ── Repository ───────────────────────────────────────────────────────────────

final userLocalRepositoryProvider = Provider<UserLocalRepository>((ref) {
  final realm = ref.watch(realmProvider);
  return UserLocalRepository(realm);
});

// ── Auth → Realm Sync ─────────────────────────────────────────────────────────

/// Supabase auth olaylarını dinler ve UserModel'i Realm'la senkronize eder.
///
/// Bu provider bir "effect" provider'ıdır.
/// Sadece `app.dart` veya `main.dart` içinde `ref.listen(userSyncProvider, (_, __) {})`
/// veya Widget içinde `ref.watch(userSyncProvider)` ile bir kez tetiklenmesi yeterlidir.
final userSyncProvider = Provider<void>((ref) {
  final userRepo = ref.watch(userLocalRepositoryProvider);

  // ref.listen: Durum her değiştiğinde provider'ı baştan yaratmak yerine
  // sadece bu callback fonksiyonunu güvenli bir şekilde tetikler.
  ref.listen(authStateChangesProvider, (previous, next) {
    next.when(
      data: (user) {
        if (user != null) {
          // Oturum açıldı: Realm'ı Supabase verisiyle eşleştir.
          userRepo.syncFromSupabaseUser(user);
        } else {
          // Oturum kapandı.
          userRepo.onSignOut();
        }
      },
      loading: () {
        // Yüklenme durumunda yapılacak bir işlem yok.
      },
      error: (error, stackTrace) {
        // İleride buraya Crashlytics veya loglama eklenebilir.
      },
    );
  });
});
