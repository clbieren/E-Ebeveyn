import 'package:realm/realm.dart';

// Realm kod üreteci tarafından oluşturulacak dosya.
// Çalıştırma: dart run realm generate
part 'user_model.realm.dart';

/// Uygulamayı kullanan kişiyi temsil eden Realm modeli.
///
/// [supabaseId] ve [email] şu an null olabilir. Supabase auth entegre
/// edildiğinde bu alanlar doldurulacak ve sync başlayacak.
@RealmModel()
class _UserModel {
  /// Primary key — Realm tarafında ObjectId kullanılır.
  @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;

  /// Supabase'deki kullanıcı UUID'si. Sync için eşleşme anahtarı.
  /// Auth yokken null kalır.
  @MapTo('supabase_id')
  String? supabaseId;

  /// Kullanıcının e-posta adresi. Supabase auth'tan gelecek.
  String? email;

  /// Kayıt oluşturulma zamanı (UTC).
  @MapTo('created_at')
  late DateTime createdAt;
}
