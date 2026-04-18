import 'package:realm/realm.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase show User;

import '../../../user/data/models/user_model.dart';

/// [UserModel] için Realm CRUD operasyonları.
///
/// Supabase Sync Stratejisi (`latest_timestamp_wins`):
/// Supabase'den gelen kullanıcı verisi ile local Realm kaydı karşılaştırılırken
/// [UserModel.createdAt] esas alınır. İleride gerçek sync şu akışı izler:
///   1. Supabase'den kayıt çek
///   2. Local `updatedAt` > remote `updated_at` ise local kazanır
///   3. Değilse remote veriyi Realm'a yaz
///
/// Şu an (Faz 2): Sadece auth sonrası `supabaseId` eşleştirilmesi yapılır.
final class UserLocalRepository {
  const UserLocalRepository(this._realm);

  final Realm _realm;

  // ── Sorgular ────────────────────────────────────────────────────────────────

  /// Realm'daki ilk (ve tek beklenen) kullanıcıyı döner.
  UserModel? getLocalUser() {
    return _realm.all<UserModel>().firstOrNull;
  }

  /// Supabase ID'ye göre kullanıcıyı arar.
  UserModel? findBySupabaseId(String supabaseId) {
    return _realm
        .all<UserModel>()
        .query(r'supabase_id == $0', [supabaseId]).firstOrNull;
  }

  // ── Sync ────────────────────────────────────────────────────────────────────

  /// Başarılı Supabase auth sonrası çağrılır.
  ///
  /// Akış:
  /// 1. Bu supabaseId'ye ait kayıt var mı?
  ///    - Varsa → email güncelle (değişmiş olabilir)
  ///    - Yoksa → yeni UserModel oluştur
  ///
  /// Bu metod `latest_timestamp_wins` için zemin hazırlar:
  /// ileride `updatedAt` karşılaştırması buraya eklenecek.
  Future<void> syncFromSupabaseUser(supabase.User supabaseUser) async {
    final existing = findBySupabaseId(supabaseUser.id);

    _realm.write(() {
      if (existing != null) {
        // Kayıt mevcut: sadece değişmiş alanları güncelle.
        existing.email = supabaseUser.email;
        // Not: Burada updatedAt güncellenmiyor çünkü UserModel'de şimdilik yok.
        // Faz 3'te Supabase tablosundan çekilen updated_at ile karşılaştırma yapılacak.
      } else {
        // İlk giriş: yeni UserModel oluştur.
        _realm.add(
          UserModel(
            ObjectId(),
            DateTime.now().toUtc(),
            supabaseId: supabaseUser.id,
            email: supabaseUser.email,
          ),
        );
      }
    });
  }

  /// Oturum kapatıldığında çağrılır.
  ///
  /// Local kullanıcı kaydı SİLİNMEZ — offline veri korunur.
  /// Sadece `supabaseId` null'a çekilir (isteğe bağlı, şimdilik pass).
  void onSignOut() {
    // Kasıtlı boş bırakıldı: Offline-first mimaride lokal veri oturumdan
    // bağımsızdır. Veri silme sadece "Hesabı Sil" akışında yapılacak.
  }
}
