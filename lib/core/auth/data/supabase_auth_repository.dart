import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../domain/auth_failure.dart';
import '../domain/auth_repository.dart';

/// Supabase auth implementasyonu.
///
/// Tüm Supabase AuthException'ları [AuthFailure]'a çevirir.
class SupabaseAuthRepository implements AuthRepository {
  const SupabaseAuthRepository(this._supabase);

  final supabase.SupabaseClient _supabase;

  @override
  Stream<supabase.User?> get authStateChanges =>
      _supabase.auth.onAuthStateChange.map((event) => event.session?.user);

  @override
  supabase.User? get currentUser => _supabase.auth.currentUser;

  @override
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
      );
    } on supabase.AuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on supabase.AuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on supabase.AuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  /// Supabase AuthException'ları domain failure'larına çevirir.
  AuthFailure _mapAuthException(supabase.AuthException e) {
    return switch (e.statusCode) {
      '400' => const InvalidCredentials(),
      '422' => switch (e.message) {
          'User already registered' => const EmailAlreadyInUse(),
          'Email not confirmed' => const EmailNotConfirmed(),
          'Password should be at least 6 characters' => const WeakPassword(),
          _ => UnknownAuthFailure(e.message),
        },
      '429' => const TooManyRequests(),
      _ => UnknownAuthFailure(e.message),
    };
  }
}
