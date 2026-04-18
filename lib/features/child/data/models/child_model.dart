import 'package:realm/realm.dart';

// Realm kod üreteci tarafından oluşturulacak dosya.
// Çalıştırma: dart run realm generate
part 'child_model.realm.dart';

/// Takibi yapılan çocuğu temsil eden Realm modeli.
///
/// [syncId] → UUID formatında, cihazlar arası eşleşme için kullanılır.
/// Supabase tablosundaki `id` (uuid primary key) ile birebir eşleşir.
/// Bu sayede ObjectId (Realm) ve UUID (Supabase) arasında köprü kurulur.
@RealmModel()
class _ChildModel {
  /// Realm yerel primary key.
  @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;

  /// UUID — Supabase ile sync ve çoklu cihaz eşleşmesi için.
  /// [uuid] paketi ile üretilmeli: `const Uuid().v4()`
  @MapTo('sync_id')
  @Indexed()
  late String syncId;

  /// Çocuğun adı.
  late String name;

  /// Cinsiyet bilgisi.
  late String gender;

  /// Boy (cm)
  late double height;

  /// Kilo (kg)
  late double weight;

  /// Doğum tarihi. Yaş hesaplamaları bu alandan yapılır.
  @MapTo('birth_date')
  late DateTime birthDate;

  /// Kayıt oluşturulma zamanı (UTC).
  @MapTo('created_at')
  late DateTime createdAt;

  /// Son güncelleme zamanı (UTC).
  /// Supabase sync sırasında `latest_timestamp_wins` stratejisi için kullanılır.
  @MapTo('updated_at')
  late DateTime updatedAt;

  /// Supabase'e sync edildi mi?
  @MapTo('is_synced')
  late bool isSynced = false;
}
