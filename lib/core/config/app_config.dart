/// Ortam değişkenlerini okumak için merkezi yapılandırma sınıfı.
///
/// Değerler `--dart-define` veya `--dart-define-from-file` ile enjekte edilir.
/// Bu yaklaşım sıfır ek paket gerektirir ve CI/CD ile uyumludur.
///
/// Geliştirme ortamında çalıştırma:
/// ```bash
/// flutter run \
///   --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=eyJhb...
/// ```
///
/// Dosyadan okuma (.env.json şeklinde — .gitignore'a eklenmeli):
/// ```bash
/// flutter run --dart-define-from-file=.env.json
/// ```
///
/// .env.json içeriği:
/// ```json
/// {
///   "SUPABASE_URL": "https://xxxx.supabase.co",
///   "SUPABASE_ANON_KEY": "eyJhb..."
/// }
/// ```
abstract final class AppConfig {
  AppConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'https://nmhfuuolcgqtzqtzdlxk.supabase.co',
    // Geliştirme sırasında fallback — ASLA production değeri yazılmaz.
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5taGZ1dW9sY2dxdHpxdHpkbHhrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUzNzYyNzMsImV4cCI6MjA5MDk1MjI3M30.vfbz4JLMcT4AYwzcHkvNQBAtdsUQjnbJCSWhdGzRLag',
    defaultValue: '',
  );

  /// Supabase yapılandırmasının eksik olup olmadığını kontrol eder.
  /// main() içinde assert ile kullanılır.
  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
