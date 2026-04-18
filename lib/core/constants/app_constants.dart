/// Uygulama genelinde kullanılan sabit değerler.
///
/// Magic number kullanımını önlemek için tüm sabitler buraya taşınmalıdır.
abstract final class AppConstants {
  AppConstants._();

  // ── Realm ─────────────────────────────────────────────────────────────────
  /// Local Realm şema versiyonu. Şema değiştiğinde artırılmalı ve
  /// migration bloğu [RealmConfig] içine eklenmelidir.
  static const int realmSchemaVersion = 4;

  /// Realm veritabanı dosya adı.
  static const String realmFileName = 'babytracker.realm';

  // ── Supabase ──────────────────────────────────────────────────────────────
  static const String supabaseUrl = '';
  static const String supabaseAnonKey = '';

  // ── Event Types ───────────────────────────────────────────────────────────
  /// Realm'da string olarak saklanan event tipleri.
  static const String eventTypeSleep = 'sleep';
  static const String eventTypeFeed = 'feed';
  static const String eventTypeDiaper = 'diaper';

  static const List<String> validEventTypes = [
    eventTypeSleep,
    eventTypeFeed,
    eventTypeDiaper,
  ];

  // ── Event Sub-Types ───────────────────────────────────────────────────────
  /// Beslenme alt tipleri.
  static const String feedSubBreastMilk = 'breast_milk'; // Anne Sütü
  static const String feedSubFormula = 'formula'; // Mama

  /// Bez alt tipleri.
  static const String diaperSubDirty = 'dirty'; // Kirli
  static const String diaperSubWet = 'wet'; // Islak
  static const String diaperSubClean = 'clean'; // Temiz (önleyici değişim)

  // ── UI ────────────────────────────────────────────────────────────────────
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 16.0;
  static const double bottomSheetBorderRadius = 24.0;
}
