import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/supabase_auth_repository.dart';
import '../domain/auth_repository.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository(ref.watch(supabaseClientProvider));
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authRepositoryProvider).currentUser;
});
