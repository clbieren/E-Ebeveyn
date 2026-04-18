import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:babytracker/core/auth/auth_provider.dart';
import 'package:babytracker/core/bootstrap/growth_reminder_bootstrap.dart';
import 'package:babytracker/core/sync/providers/sync_providers.dart';
import 'package:babytracker/features/auth/presentation/login_screen.dart';
import 'package:babytracker/features/main/presentation/main_layout.dart';
import 'package:babytracker/features/user/providers/user_providers.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(userSyncProvider);
    ref.watch(syncOrchestratorProvider);

    return MaterialApp(
      title: 'Baby Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF2C2C2C),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF3A3A3A),
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C2C2C),
          elevation: 0,
        ),
      ),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends ConsumerWidget {
  const _AuthGate();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    return authState.when(
      loading: () => const _Splash(),
      error: (_, __) => const LoginScreen(),
      data: (user) => user == null
          ? const LoginScreen()
          : const GrowthReminderBootstrap(body: MainLayout()),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(cs.primary),
        ),
      ),
    );
  }
}
