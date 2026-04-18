import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/auth/auth_provider.dart';
import '../../domain/auth_failure.dart';

final loginControllerProvider =
    StateNotifierProvider<LoginController, AsyncValue<void>>(
  (ref) => LoginController(ref),
);

class LoginController extends StateNotifier<AsyncValue<void>> {
  LoginController(this.ref) : super(const AsyncData(null));

  final Ref ref;

  Future<bool?> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(authNotifierProvider.notifier).signIn(
            email: email.trim(),
            password: password,
          );

      final hasFamily = await _checkFamilyId();
      state = const AsyncData(null);
      return hasFamily;
    } on AuthFailure catch (e, st) {
      state = AsyncError(e, st);
      return null;
    } catch (e, st) {
      state = AsyncError(UnknownAuthFailure(e.toString()), st);
      return null;
    }
  }

  Future<bool?> signUp({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(authNotifierProvider.notifier).signUp(
            email: email.trim(),
            password: password,
          );

      final hasFamily = await _checkFamilyId();
      state = const AsyncData(null);
      return hasFamily;
    } on AuthFailure catch (e, st) {
      state = AsyncError(e, st);
      return null;
    } catch (e, st) {
      state = AsyncError(UnknownAuthFailure(e.toString()), st);
      return null;
    }
  }

  void resetState() {
    state = const AsyncData(null);
  }

  Future<bool> _checkFamilyId() async {
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) return false;

      final profileResponse = await client
          .from('profiles')
          .select('family_id')
          .eq('id', userId)
          .maybeSingle();

      final familyId = profileResponse?['family_id'];
      return familyId != null && familyId.toString().isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

extension LoginControllerStateX on AsyncValue<void> {
  String? get errorMessage {
    return when(
      data: (_) => null,
      loading: () => null,
      error: (e, _) {
        if (e is AuthFailure) return e.userMessage;
        return 'Bir hata oluştu. Lütfen tekrar deneyin.';
      },
    );
  }
}
