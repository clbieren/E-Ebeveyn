import 'package:realm/realm.dart';
import 'package:uuid/uuid.dart' as uuid;

import '../../../event_log/data/models/event_log_model.dart';
import '../models/child_model.dart';

/// [ChildModel] için tüm Realm operasyonları.
///
/// Tasarım ilkesi: Her public metod atomik ve idempotent olmalı.
/// Realm write transaction'ları dışarıya sızdırılmaz.
final class ChildRepository {
  const ChildRepository(this._realm);

  final Realm _realm;

  // ── Sorgular ─────────────────────────────────────────────────────────────

  /// Tüm çocukları döner. Realm sonuçları lazy — büyük veri setlerinde güvenli.
  RealmResults<ChildModel> getAll() {
    return _realm.all<ChildModel>().query('TRUEPREDICATE SORT(createdAt ASC)');
  }

  /// Bir çocuğun var olup olmadığını kontrol eder.
  /// [getAll().isEmpty] yerine bu kullanılmalı — tam sorgu yerine sadece count.
  bool hasAnyChild() => _realm.all<ChildModel>().isNotEmpty;

  /// [id] ile tek çocuk döner. Bulunamazsa null.
  ChildModel? findById(ObjectId id) => _realm.find<ChildModel>(id);

  /// [syncId] ile tek çocuk döner. Bulunamazsa null.
  ChildModel? findBySyncId(String syncId) =>
      _realm.all<ChildModel>().query(r'sync_id == $0', [syncId]).firstOrNull;

  // ── Yazma ────────────────────────────────────────────────────────────────

  /// Yeni bir [ChildModel] oluşturur ve Realm'a yazar.
  ///
  /// Returns: Oluşturulan kaydın [ObjectId]'si.
  ObjectId create({
    required String name,
    required String gender,
    required double height,
    required double weight,
    required DateTime birthDate,
  }) {
    final now = DateTime.now().toUtc();
    final id = ObjectId();

    _realm.write(() {
      _realm.add(
        ChildModel(
          id,
          const uuid.Uuid().v4(), // syncId: Supabase UUID köprüsü
          name.trim(),
          gender.trim(),
          height,
          weight,
          birthDate.toUtc(),
          now,
          now,
          isSynced: false,
        ),
      );
    });

    return id;
  }

  /// Çocuğun boy ve kilo ölçümlerini günceller.
  ///
  /// Her iki değer de aynı Realm write transaction'ı içinde atomik olarak
  /// yazılır. Sync stratejisi için `updatedAt` ve `isSynced` alanları
  /// güncellenir.
  void updateMeasurements(ObjectId id,
      {required double height, required double weight}) {
    final child = _realm.find<ChildModel>(id);
    if (child == null) return;

    _realm.write(() {
      child
        ..height = height
        ..weight = weight
        ..updatedAt = DateTime.now().toUtc()
        ..isSynced = false;
    });
  }

  /// Çocuk adını günceller.
  void updateName(ObjectId id, String name) {
    final child = _realm.find<ChildModel>(id);
    if (child == null) return;

    _realm.write(() {
      child
        ..name = name.trim()
        ..updatedAt = DateTime.now().toUtc()
        ..isSynced = false;
    });
  }

  /// Çocuğu ve tüm ilgili event log'larını lokalde kalıcı olarak siler.
  void delete(ObjectId id) {
    final child = _realm.find<ChildModel>(id);
    if (child == null) return;

    // Sadece silinecek çocuğa ait EventLog'ları bul
    final events = _realm.all<EventLogModel>().query(
        r'childId == $0', [id]).toList(); // Use mapped object property name

    _realm.write(() {
      _realm.deleteMany(events);
      _realm.delete(child);
    });
  }
}
