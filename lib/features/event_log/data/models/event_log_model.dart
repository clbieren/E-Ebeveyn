import 'package:realm/realm.dart';

part 'event_log_model.realm.dart';

/// Uyku, beslenme ve bez değişimi için ortak olay kaydı modeli.
///
/// Şema Geçmişi:
///   v1 — İlk sürüm
///   v2 — syncId alanı eklendi (UUID, Supabase köprüsü)
///   v3 — subType alanı eklendi (nullable, beslenme/bez alt kategorisi)
///
/// [eventType] + [subType] ilişkisi:
///   sleep   → subType = null (alt kategori yok)
///   feed    → subType = 'breast_milk' | 'formula'
///   diaper  → subType = 'dirty' | 'wet' | 'clean'
@RealmModel()
class _EventLogModel {
  @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;

  /// UUID — Supabase event_logs.id ile birebir eşleşir.
  @MapTo('sync_id')
  @Indexed()
  late String syncId;

  /// İlişkili çocuğun Realm ObjectId'si (local foreign key).
  @MapTo('child_id')
  @Indexed()
  late ObjectId childId;

  /// Olay tipi: 'sleep' | 'feed' | 'diaper'
  @MapTo('event_type')
  @Indexed()
  late String eventType;

  /// Alt kategori. sleep için null; feed/diaper için zorunlu.
  /// Geçerli değerler AppConstants'ta tanımlı.
  @MapTo('sub_type')
  String? subType;

  /// Olayın başlangıç zamanı (UTC).
  @MapTo('start_time')
  late DateTime startTime;

  /// Olayın bitiş zamanı (UTC). Aktif olaylarda null.
  @MapTo('end_time')
  DateTime? endTime;

  /// Ebeveynin ekleyebileceği serbest metin notu.
  String? note;

  /// Supabase'e sync edildi mi?
  @MapTo('is_synced')
  late bool isSynced;

  @MapTo('created_at')
  late DateTime createdAt;

  /// KRİTİK: Her write'ta güncellenmeli — latest_timestamp_wins için.
  @MapTo('updated_at')
  late DateTime updatedAt;
}
