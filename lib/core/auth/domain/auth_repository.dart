import 'package:supabase_flutter/supabase_flutter.dart' as supabase show User;

/// Auth işlemlerini yöneten repository interface.
///
/// Tüm auth hataları [AuthFailure] olarak döner — asla exception fırlatmaz.
abstract class AuthRepository {
  /// Auth state değişikliklerini dinler.
  ///
  /// İlk değer mevcut oturum, sonrasında login/logout değişiklikleri.
  Stream<supabase.User?> get authStateChanges;

  /// Mevcut oturumdaki kullanıcı.
  supabase.User? get currentUser;

  /// Email ve şifre ile kayıt olur.
  ///
  /// Başarılı olursa [authStateChanges] stream'i yeni kullanıcıyı yayınlar.
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  });

  /// Email ve şifre ile giriş yapar.
  ///
  /// Başarılı olursa [authStateChanges] stream'i yeni kullanıcıyı yayınlar.
  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  /// Mevcut oturumu kapatır.
  ///
  /// Başarılı olursa [authStateChanges] stream'i null yayınlar.
  Future<void> signOut();
}
