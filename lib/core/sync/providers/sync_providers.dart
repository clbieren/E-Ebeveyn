import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../../connectivity/providers/connectivity_provider.dart';
import '../../db/providers/realm_provider.dart';
import '../sync_repository.dart';

enum SyncStatus { idle, syncing, success, failure }

class SyncState {
  const SyncState({
    this.isSyncing = false,
    this.isSuccess = false,
    this.lastPulledCount = 0,
    this.lastPushedCount = 0,
    this.status = SyncStatus.idle,
    this.message,
  });

  final bool isSyncing;
  final bool isSuccess;
  final int lastPulledCount;
  final int lastPushedCount;
  final SyncStatus status;
  final String? message;
}

class SyncOrchestrator extends StateNotifier<SyncState> {
  SyncOrchestrator(this._ref) : super(const SyncState());

  final Ref _ref;

  Future<void> triggerManualSync() async {
    state = const SyncState(
      isSyncing: true,
      status: SyncStatus.syncing,
    );

    try {
      final user = _ref.read(currentUserProvider);
      if (user == null) {
        state = const SyncState(
          isSyncing: false,
          isSuccess: false,
          status: SyncStatus.failure,
          message: 'Oturum bulunamadı.',
        );
        return;
      }

      final isOnline = await _ref.read(connectivityProvider.future);
      if (!isOnline) {
        state = const SyncState(
          isSyncing: false,
          isSuccess: true,
          status: SyncStatus.success,
          message: 'İnternet yok. Yerel kayıtlar korunuyor.',
        );
        return;
      }

      final result = await _ref.read(syncRepositoryProvider).sync(
            userId: user.id,
            isOnline: isOnline,
          );

      state = SyncState(
        isSyncing: false,
        isSuccess: true,
        lastPulledCount: result.pulledCount,
        lastPushedCount: result.pushedCount,
        status: SyncStatus.success,
        message: result.errorMessage,
      );
    } on SyncException catch (e) {
      state = const SyncState(
        isSyncing: false,
        isSuccess: false,
        status: SyncStatus.failure,
        message: null,
      );
      state = SyncState(
        isSyncing: false,
        isSuccess: false,
        status: SyncStatus.failure,
        message: e.userMessage,
      );
    } catch (_) {
      state = const SyncState(
        isSyncing: false,
        isSuccess: false,
        status: SyncStatus.failure,
        message: 'Senkronizasyon başarısız. Lütfen tekrar deneyin.',
      );
    }
  }
}

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  return SyncRepository(
    ref.watch(realmProvider),
    ref.watch(supabaseClientProvider),
  );
});

final syncOrchestratorProvider =
    StateNotifierProvider<SyncOrchestrator, SyncState>(
  (ref) => SyncOrchestrator(ref),
);
