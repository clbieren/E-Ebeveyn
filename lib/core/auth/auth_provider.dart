import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:babytracker/core/auth/domain/auth_failure.dart';
import 'package:babytracker/core/db/providers/realm_provider.dart';

part 'auth_provider.g.dart';

/// Auth state yöneticisi.
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  static final navigatorKey = GlobalKey<NavigatorState>();
  bool _isProvisioningFromStream = false;

  @override
  AsyncValue<User?> build() {
    // Auth stream'ini dinle
    final sub = Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      _handleAuthStateChange(event.session?.user);
    });
    ref.onDispose(sub.cancel);

    // İlk değer
    return AsyncData(Supabase.instance.client.auth.currentUser);
  }

  Future<void> _handleAuthStateChange(User? user) async {
    if (user == null) {
      state = const AsyncData(null);
      return;
    }

    if (_isProvisioningFromStream) return;
    _isProvisioningFromStream = true;
    state = const AsyncLoading();
    try {
      await _provisionProfileAndFamily(user);
      state = AsyncData(user);
    } on PostgrestException catch (e) {
      state = AsyncError(
        UnknownAuthFailure('Kurulum Yapiliyor: ${e.message}'),
        StackTrace.current,
      );
    } catch (e) {
      state = AsyncError(
        UnknownAuthFailure('Kurulum Yapiliyor: $e'),
        StackTrace.current,
      );
    } finally {
      _isProvisioningFromStream = false;
    }
  }

  // ── Giriş ──────────────────────────────────────────────────────────────────

  /// E-posta ve şifre ile giriş.
  ///
  /// Hata garantisi: catch bloğu her zaman [AsyncError] yazar.
  /// Yanlış şifre → sonsuz döner değil, anında hata state'i.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final response = await Supabase.instance.client.auth
          .signInWithPassword(email: email.trim(), password: password);
      final user = response.user ?? Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await _provisionProfileAndFamily(user);
      }
      // Başarı state'i auth stream'i tarafından otomatik yazılır
    } on AuthException catch (e) {
      final error = _mapError(e);
      state = AsyncError(error, StackTrace.current);
      throw error;
    } catch (e) {
      const error = NetworkError();
      state = AsyncError(error, StackTrace.current);
      throw error;
    }
  }

  /// E-posta ve şifre ile kayıt.
  ///
  /// Provision hatası kullanıcıyı logout etmez — oturumda kalır,
  /// FamilyDecisionScreen üzerinden aile kurulumu yapabilir.
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    // Stream race condition'ı önle: signUp süreci devam ederken
    // onAuthStateChange callback'i state'i ezmemeli.
    _isProvisioningFromStream = true;
    try {
      final response = await Supabase.instance.client.auth
          .signUp(email: email.trim(), password: password);
      final user = response.user ?? Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw const UnknownAuthFailure(
          'Kayit tamamlanamadi. Lutfen e-posta dogrulamasini kontrol edin.',
        );
      }
      // Provision best-effort: hata olsa bile kullanıcıyı logout ETME.
      // Kullanıcı FamilyDecisionScreen'e gider, orada aile kurulumunu yapar.
      try {
        await _provisionProfileAndFamily(user);
      } catch (_) {
        // Provision başarısız — family_id NULL kalır.
        // hasFamilyProvider bunu okuyunca false döner → FamilyDecisionScreen.
      }
      state = AsyncData(user);
    } on AuthException catch (e) {
      final error = _mapError(e);
      state = AsyncError(error, StackTrace.current);
      throw error;
    } on AuthFailure catch (e) {
      state = AsyncError(e, StackTrace.current);
      throw e;
    } catch (e) {
      const error = NetworkError();
      state = AsyncError(error, StackTrace.current);
      throw error;
    } finally {
      _isProvisioningFromStream = false;
    }
  }

  // ── Çıkış ──────────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();

    try {
      final realm = ref.read(realmProvider);
      realm.write(() => realm.deleteAll());
    } catch (_) {}

    state = const AsyncData(null);
  }

  Future<void> _provisionProfileAndFamily(User user) async {
    await Supabase.instance.client.from('profiles').upsert(
      {'id': user.id},
      onConflict: 'id',
    );
  }

  // ── Hata Mapping ───────────────────────────────────────────────────────────

  AuthFailure _mapError(AuthException e) {
    final code = e.statusCode;
    final message = e.message.toLowerCase();

    if (code == '400') {
      if (message.contains('invalid login credentials') ||
          message.contains('invalid email or password')) {
        return const InvalidCredentials();
      }
      if (message.contains('email not confirmed'))
        return const EmailNotConfirmed();
      if (message.contains('password should be at least'))
        return const WeakPassword();
      if (message.contains('already registered'))
        return const EmailAlreadyInUse();
    }
    if (code == '422') {
      if (message.contains('password')) return const WeakPassword();
      if (message.contains('email')) return const EmailAlreadyInUse();
    }
    if (code == '429') return const TooManyRequests();

    return UnknownAuthFailure(e.message);
  }
}
