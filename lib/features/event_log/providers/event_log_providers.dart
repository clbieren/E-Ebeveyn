import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/db/providers/realm_provider.dart';
import '../../reports/providers/reports_providers.dart';
import '../data/models/event_log_model.dart';
import '../data/repositories/event_log_repository.dart';
import '../../child/providers/child_providers.dart';
import '../../../../core/widgets/home_widget_service.dart';
import 'package:realm/realm.dart';

part 'event_log_providers.g.dart';

// ── Repository ───────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
EventLogRepository eventLogRepository(Ref ref) {
  return EventLogRepository(ref.watch(realmProvider));
}

// ── Bugünkü Event'ler (Zorunlu Tetikleme) ──────────────────────────────────

@riverpod
Stream<List<EventLogModel>> todayEvents(Ref ref) async* {
  final childId = ref.watch(selectedChildIdProvider);
  if (childId == null) {
    yield [];
    return;
  }

  final results = ref.watch(eventLogRepositoryProvider).getTodayEvents(childId);

  // UI'ın sonsuz yüklemede kalmasını engellemek için İLK veriyi zorla basıyoruz!
  yield results.toList();

  await for (final c in results.changes) {
    yield c.results.toList();
  }
}

// ── Son Aktiviteler (Realm LIMIT Bypass) ───────────────────────────────────

@riverpod
Stream<List<EventLogModel>> recentEvents(Ref ref, {int limit = 8}) async* {
  final childId = ref.watch(selectedChildIdProvider);
  if (childId == null) {
    yield [];
    return;
  }

  // DİKKAT: Realm'in LIMIT bug'ını aşmak için limiti DB'ye sormuyoruz,
  // tüm listeyi çekip Dart tarafında kesiyoruz!
  final realm = ref.watch(realmProvider);
  final results = realm.all<EventLogModel>().query(
    r'child_id == $0 SORT(start_time DESC)',
    [childId],
  );

  // Ekrana ilk açıldığı an listeyi fırlatır (take ile limitliyoruz)
  yield results.take(limit).toList();

  await for (final c in results.changes) {
    yield c.results.take(limit).toList();
  }
}

// ── Actions & Refresh ────────────────────────────────────────────────────────

final activityActionsProvider = Provider<ActivityActions>((ref) {
  return ActivityActions(ref);
});

final eventStateRefreshProvider = Provider<EventStateRefresh>((ref) {
  return EventStateRefresh(ref);
});

class EventStateRefresh {
  EventStateRefresh(this._ref);

  final Ref _ref;

  void refreshAllEventStates() {
    // recentEventsProvider buradan tamamen silindi, Realm kendi halledecek.
    _ref.invalidate(dailyReportBundleProvider);
    HomeWidgetService.updateWidgetState(
        null); // Widget'ı app'teki verilerle tazele
  }
}

class ActivityActions {
  ActivityActions(this._ref);

  final Ref _ref;

  /// Uyku: seçilen süre kadar geriye dönük kayıt (bitiş = şimdi).
  void logSleepDuration(Duration duration, {String? note}) {
    final childId = _ref.read(selectedChildIdProvider);
    if (childId == null) return;

    final end = DateTime.now().toUtc();
    final start = end.subtract(duration);
    _ref.read(eventLogRepositoryProvider).logSleepWindow(
          childId: childId,
          startUtc: start,
          endUtc: end,
          note: note,
        );
    _ref.read(eventStateRefreshProvider).refreshAllEventStates();
  }

  void logFeed({
    required String subType,
    int? amountMl,
  }) {
    final note = amountMl == null ? null : 'Miktar: $amountMl ml';
    _log(
      eventType: AppConstants.eventTypeFeed,
      subType: subType,
      note: note,
    );
  }

  void logDiaper({
    required String subType,
  }) {
    _log(
      eventType: AppConstants.eventTypeDiaper,
      subType: subType,
    );
  }

  void _log({
    required String eventType,
    String? subType,
    String? note,
  }) {
    final childId = _ref.read(selectedChildIdProvider);
    if (childId == null) return;

    _ref.read(eventLogRepositoryProvider).logInstant(
          childId: childId,
          eventType: eventType,
          subType: subType,
          note: note,
        );

    _ref.read(eventStateRefreshProvider).refreshAllEventStates();
  }
}
