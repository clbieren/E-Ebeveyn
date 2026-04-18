/// Auth katmanından yayılan hatalar için sealed sınıf hiyerarşisi.
///
/// Neden Exception fırlatmıyoruz?
/// Sealed class kullanmak, çağıran tarafın her hata durumunu
/// exhaustive switch ile ele almasını zorunlu kılar. Bu sayede
/// "unhandled error" durumu derleme zamanında yakalanır.
///
/// UI katmanında kullanım:
/// ```dart
/// switch (failure) {
///   case InvalidCredentials() => 'E-posta veya şifre hatalı.';
///   case EmailNotConfirmed()  => 'Lütfen e-postanızı doğrulayın.';
///   ...
/// }
/// ```
sealed class AuthFailure implements Exception {
  const AuthFailure();

  /// Kullanıcıya gösterilecek okunabilir mesaj.
  String get userMessage;
}

/// E-posta veya şifre hatalı.
final class InvalidCredentials extends AuthFailure {
  const InvalidCredentials();

  @override
  String get userMessage => 'E-posta adresi veya şifre hatalı.';
}

/// E-posta adresi zaten kayıtlı.
final class EmailAlreadyInUse extends AuthFailure {
  const EmailAlreadyInUse();

  @override
  String get userMessage => 'Bu e-posta adresi zaten kullanımda.';
}

/// E-posta doğrulaması henüz yapılmamış.
final class EmailNotConfirmed extends AuthFailure {
  const EmailNotConfirmed();

  @override
  String get userMessage =>
      'Lütfen e-posta adresinizi doğrulayın ve tekrar deneyin.';
}

/// Ağ bağlantısı yok veya istek zaman aşımına uğradı.
final class NetworkError extends AuthFailure {
  const NetworkError();

  @override
  String get userMessage =>
      'Bağlantı hatası. İnternet bağlantınızı kontrol edin.';
}

/// Çok fazla başarısız giriş denemesi.
final class TooManyRequests extends AuthFailure {
  const TooManyRequests();

  @override
  String get userMessage =>
      'Çok fazla deneme yapıldı. Lütfen birkaç dakika bekleyin.';
}

/// Zayıf şifre (kayıt sırasında).
final class WeakPassword extends AuthFailure {
  const WeakPassword();

  @override
  String get userMessage => 'Şifre en az 8 karakter olmalıdır.';
}

/// Tanımlanmayan, beklenmeyen Supabase hatası.
final class UnknownAuthFailure extends AuthFailure {
  const UnknownAuthFailure(this.message);
  final String message;

  @override
  String get userMessage => 'Bir hata oluştu. Lütfen tekrar deneyin.';
}
