import 'package:realm/realm.dart' hide Uuid;
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/event_log_model.dart';

/// [EventLogModel] için tüm Realm operasyonları.
final class EventLogRepository {
  const EventLogRepository(this._realm);

  final Realm _realm;

  // ── Sorgular ─────────────────────────────────────────────────────────────

  /// Seçili çocuğun bugünkü tüm event log'larını döner (startTime DESC).
  RealmResults<EventLogModel> getTodayEvents(ObjectId childId) {
    final todayStart = _todayStartUtc();
    return _realm.all<EventLogModel>().query(
      r'child_id == $0 AND start_time >= $1 SORT(start_time DESC)',
      [childId, todayStart],
    );
  }

  /// Seçili çocuğun son [limit] adet event log'unu döner (startTime DESC).
  RealmResults<EventLogModel> getRecent(ObjectId childId, {int limit = 10}) {
    return _realm.all<EventLogModel>().query(
      r'child_id == $0 SORT(start_time DESC) LIMIT($1)',
      [childId, limit],
    );
  }

  // ── Yazma ────────────────────────────────────────────────────────────────

  /// Anlık event kaydı oluşturur (endTime = startTime → süre sıfır).
  ///
  /// [subType] — feed/diaper için zorunlu; sleep için null.
  ObjectId logInstant({
    required ObjectId childId,
    required String eventType,
    String? subType,
    String? note,
  }) {
    final now = DateTime.now().toUtc();
    final id = ObjectId();

    _realm.write(() {
      _realm.add(
        EventLogModel(
          id,
          const Uuid().v4(),
          childId,
          eventType,
          now, // startTime
          false, // isSynced
          now, // createdAt
          now, // updatedAt
          endTime: now,
          subType: subType,
          note: note,
        ),
      );
    });

    return id;
  }

  /// Başlangıç kaydeder — endTime null (devam ediyor).
  ObjectId logStart({
    required ObjectId childId,
    required String eventType,
    String? subType,
    String? note,
  }) {
    final now = DateTime.now().toUtc();
    final id = ObjectId();

    _realm.write(() {
      _realm.add(
        EventLogModel(
          id,
          const Uuid().v4(),
          childId,
          eventType,
          now,
          false,
          now,
          now,
          subType: subType,
          note: note,
        ),
      );
    });

    return id;
  }

  /// Devam eden olayı tamamlar (endTime doldurur).
  void finishEvent(ObjectId id) {
    final event = _realm.find<EventLogModel>(id);
    if (event == null) return;

    final now = DateTime.now().toUtc();
    _realm.write(() {
      event
        ..endTime = now
        ..updatedAt = now;
    });
  }

  /// Bitmiş uyku aralığı (başlangıç–bitiş UTC). Grafik ve özet için süre > 0 olur.
  ObjectId logSleepWindow({
    required ObjectId childId,
    required DateTime startUtc,
    required DateTime endUtc,
    String? note,
  }) {
    final id = ObjectId();
    final now = DateTime.now().toUtc();
    _realm.write(() {
      _realm.add(
        EventLogModel(
          id,
          const Uuid().v4(),
          childId,
          AppConstants.eventTypeSleep,
          startUtc.toUtc(),
          false,
          now,
          now,
          endTime: endUtc.toUtc(),
          note: note,
        ),
      );
    });
    return id;
  }

  /// Event log'u siler.
  void delete(ObjectId id) {
    final event = _realm.find<EventLogModel>(id);
    if (event == null) return;
    _realm.write(() => _realm.delete(event));
  }

  // ── Private ───────────────────────────────────────────────────────────────

  DateTime _todayStartUtc() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).toUtc();
  }
}
