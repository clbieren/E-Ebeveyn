import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'core/auth/auth_provider.dart';
import 'core/bootstrap/growth_reminder_bootstrap.dart';
import 'core/notifications/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/home_widget_service.dart';
import 'features/child/providers/child_providers.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/main/presentation/main_layout.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/onboarding/presentation/family_decision_screen.dart';

/// Kullanıcının Supabase `profiles` tablosunda geçerli bir `family_id`'ye
/// sahip olup olmadığını kontrol eder.
///
/// Provider, [userId]'yi parametre olarak alır. Bu sayede kullanıcı
/// değiştiğinde (yeni kayıt, oturum geçişi) Riverpod cache'i farklı
/// key'e karşılık gelir ve asla eski oturumun değerini döndürmez.
///
/// `true`  → profilde non-null, non-'null' bir family_id var.
/// `false` → family_id yok; kullanıcı henüz aile bağlamına sahip değil.
final hasFamilyProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, userId) async {
  final rows = await Supabase.instance.client
      .from('profiles')
      .select('family_id')
      .eq('id', userId)
      .limit(1);

  if (rows.isEmpty) return false;
  final familyId = rows.first['family_id'];
  if (familyId == null) return false;
  final familyIdStr = familyId.toString().trim();
  return familyIdStr.isNotEmpty && familyIdStr != 'null';
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HomeWidgetService.setup();

  // İŞTE O HAYAT KURTARAN VE KIRMIZI EKRANI YOK EDEN SATIR:
  await initializeDateFormatting('tr', null);

  await dotenv.load(fileName: ".env");
  await NotificationService.instance.initialize();

  // Supabase'i başlat. Bu çağrı idempotent'tir:
  // Zaten initialize edildiyse mevcut instance döner.
  await Supabase.initialize(
    url: 'https://nmhfuuolcgqtzqtzdlxk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5taGZ1dW9sY2dxdHpxdHpkbHhrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUzNzYyNzMsImV4cCI6MjA5MDk1MjI3M30.vfbz4JLMcT4AYwzcHkvNQBAtdsUQjnbJCSWhdGzRLag',
    // Debug logları sadece debug modda aktif olsun.
    debug: true,
  );

  // Durum çubuğunu şeffaf yap.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF000000),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Yalnızca dikey yönlendirme.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Google AdMob Init
  await MobileAds.instance.initialize();

  runApp(
    const ProviderScope(
      child: RootApp(),
    ),
  );
}

class RootApp extends ConsumerWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return MaterialApp(
      title: 'Baby Tracker',
      debugShowCheckedModeBanner: false,
      navigatorKey: AuthNotifier.navigatorKey,

      // TÜRKÇE DİL DESTEĞİ VE KLAVYE GARANTİSİ
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: AppTheme.dark,
      home: authState.when(
        loading: () => const _Splash(),
        error: (_, __) => const LoginScreen(),
        data: (user) {
          if (user == null) return const LoginScreen();

          final hasFamilyAsync = ref.watch(hasFamilyProvider(user.id));
          return hasFamilyAsync.when(
            loading: () => const _Splash(),
            error: (_, __) => const FamilyDecisionScreen(),
            data: (hasFamily) {
              if (!hasFamily) return const FamilyDecisionScreen();

              final hasChildAsync = ref.watch(hasAnyChildProvider);
              return hasChildAsync.when(
                loading: () => const _Splash(),
                error: (_, __) => const OnboardingScreen(),
                data: (hasChild) => hasChild
                    ? const GrowthReminderBootstrap(body: MainLayout())
                    : const OnboardingScreen(),
              );
            },
          );
        },
      ),
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
