import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:realm/realm.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/db/providers/realm_provider.dart';
import '../data/models/child_model.dart';
import '../data/repositories/child_repository.dart';
import '../../../../core/widgets/home_widget_service.dart';

part 'child_providers.g.dart';

// ── Repository ───────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
ChildRepository childRepository(Ref ref) {
  return ChildRepository(ref.watch(realmProvider));
}

// ── Çocuk Listesi (Reaktif) ──────────────────────────────────────────────────

/// Realm'daki tüm çocukları reaktif stream olarak yayınlar.
///
/// Realm'ın [RealmResults] nesnesi değişim bildirimi destekler.
/// Her ekleme/silme/güncelleme sonrası bu stream otomatik emit eder.
@riverpod
Stream<List<ChildModel>> children(Ref ref) async* {
  final results = ref.watch(childRepositoryProvider).getAll();

  yield results.toList();
  await for (final c in results.changes) {
    yield c.results.toList();
  }
}

/// Veri tabanında hiç çocuk var mı? (Routing kararı için)
///
/// Ayrı stream: [children]'den bağımsız — sadece boş/dolu bilgisi.
@riverpod
Stream<bool> hasAnyChild(Ref ref) async* {
  final results = ref.watch(childRepositoryProvider).getAll();
  yield results.isNotEmpty;
  await for (final c in results.changes) {
    yield c.results.isNotEmpty;
  }
}

// ── Seçili Çocuk ─────────────────────────────────────────────────────────────

/// Şu an aktif olan çocuğun [ObjectId]'si.
///
/// [null] → Hiç çocuk yok (OnboardingScreen'de olunması gerekir).
///
/// İlk açılışta otomatik olarak ilk çocuğu seçer.
/// Kullanıcı yatay kaydırarak farklı çocuk seçebilir.
@Riverpod(keepAlive: true)
class SelectedChildId extends _$SelectedChildId {
  @override
  ObjectId? build() {
    // Çocuk listesi değiştiğinde otomatik senkronize et.
    // Yeni çocuk eklendiyse ve seçili çocuk null ise → yeni çocuğu seç.
    ref.listen<AsyncValue<List<ChildModel>>>(childrenProvider, (_, next) {
      next.whenData((children) {
        if (children.isEmpty) {
          state = null;
          return;
        }
        // Seçili çocuk silinmişse veya henüz seçilmemişse → ilk çocuğu seç.
        final currentId = state;
        if (currentId == null || !children.any((c) => c.id == currentId)) {
          state = children.first.id;
          HomeWidgetService.updateWidgetState(state,
              childName: children.first.name);
        } else {
          final currentChild = children.firstWhere((c) => c.id == currentId);
          HomeWidgetService.updateWidgetState(currentId,
              childName: currentChild.name);
        }
      });
    });

    // İlk değer: mevcut ilk çocuk (varsa).
    final initialChild = ref.read(childRepositoryProvider).getAll().firstOrNull;
    if (initialChild != null) {
      HomeWidgetService.updateWidgetState(initialChild.id,
          childName: initialChild.name);
    }
    return initialChild?.id;
  }

  void select(ObjectId id) {
    state = id;
    final child = ref.read(childRepositoryProvider).findById(id);
    HomeWidgetService.updateWidgetState(id, childName: child?.name);
  }
}

/// Seçili [ChildModel] nesnesini döner.
///
/// [SelectedChildId] değişince otomatik güncellenir.
@riverpod
ChildModel? selectedChild(Ref ref) {
  final id = ref.watch(selectedChildIdProvider);
  if (id == null) return null;
  return ref.watch(childRepositoryProvider).findById(id);
}
