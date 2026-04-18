import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../../connectivity/providers/connectivity_provider.dart';
import '../../db/providers/realm_provider.dart';
import '../../sync/providers/sync_providers.dart';
import '../family_repository.dart';

final familyRepositoryProvider = Provider<FamilyRepository>((ref) {
  return FamilyRepository(
    ref.watch(supabaseClientProvider),
    ref.watch(realmProvider),
    ref.watch(syncRepositoryProvider),
  );
});

final familyInviteCodeProvider = FutureProvider<String?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  return ref
      .watch(familyRepositoryProvider)
      .getCurrentInviteCode(userId: user.id);
});

final familyActionsProvider = Provider<FamilyActions>((ref) {
  return FamilyActions(ref);
});

final class FamilyActionResult {
  const FamilyActionResult.success({this.code}) : errorMessage = null;
  const FamilyActionResult.failure(this.errorMessage) : code = null;

  final String? code;
  final String? errorMessage;
  bool get isSuccess => errorMessage == null;
}

final class FamilyActions {
  const FamilyActions(this._ref);

  final Ref _ref;

  Future<FamilyActionResult> createFamily() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) {
      return const FamilyActionResult.failure('Kullanici oturumu bulunamadi.');
    }

    try {
      final isOnline = await _ref.read(connectivityProvider.future);
      if (!isOnline) {
        return const FamilyActionResult.failure(
            'Sunucuya ulasilamiyor. Internet baglantinizi kontrol edin.');
      }

      final code = await _ref.read(familyRepositoryProvider).createFamily(
            userId: user.id,
            isOnline: isOnline,
          );
      _ref.invalidate(familyInviteCodeProvider);
      return FamilyActionResult.success(code: code);
    } on FamilyException catch (e) {
      return FamilyActionResult.failure(e.userMessage);
    } catch (_) {
      return const FamilyActionResult.failure(
          'Aile olusturulamadi. Lutfen tekrar deneyin.');
    }
  }

  Future<FamilyActionResult> joinFamily(String code) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) {
      return const FamilyActionResult.failure('Kullanici oturumu bulunamadi.');
    }

    try {
      final isOnline = await _ref.read(connectivityProvider.future);
      if (!isOnline) {
        return const FamilyActionResult.failure(
            'Sunucuya ulasilamiyor. Internet baglantinizi kontrol edin.');
      }

      final success = await _ref.read(familyRepositoryProvider).joinFamily(
            userId: user.id,
            code: code,
            isOnline: isOnline,
          );
      if (success) {
        _ref.invalidate(familyInviteCodeProvider);
        return const FamilyActionResult.success();
      }
      return const FamilyActionResult.failure('Aile kodu gecersiz.');
    } on FamilyException catch (e) {
      return FamilyActionResult.failure(e.userMessage);
    } catch (_) {
      return const FamilyActionResult.failure(
          'Aileye katilma islemi tamamlanamadi.');
    }
  }
}
