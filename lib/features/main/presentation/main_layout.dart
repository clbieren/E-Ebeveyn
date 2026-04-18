import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:babytracker/features/academy/presentation/academy_screen.dart';
import 'package:babytracker/features/ai_coach/presentation/ai_insight_screen.dart';
import 'package:babytracker/features/home/presentation/home_screen.dart';
import 'package:babytracker/features/media/presentation/sleep_library_screen.dart';
import 'package:babytracker/features/settings/presentation/settings_screen.dart';
import 'package:babytracker/features/home/providers/tutorial_keys.dart';

// ── 5 Sekmeli Ana Layout ──────────────────────────────────────────────────────

/// Uygulamanın 5 sekmeli kök layout'u.
///
/// KURAL — IndexedStack zorunludur:
///   • Her sekme kendi ağacını korur (scroll pozisyonu, state kaybolmaz).
///   • Tab geçişleri anlık; ekstra build maliyeti yok.
///
/// Tab sırası (simetrik 5'li):
///   0  Ana Sayfa   → HomeScreen
///   1  AI Koç      → AiCoachScreen (ileride)
///   2  Uyku        → SleepLibraryScreen (ileride)
///   3  Akademi     → AcademyScreen
///   4  Ayarlar     → SettingsScreen
class MainLayout extends HookConsumerWidget {
  const MainLayout({super.key});

  // Sekme metadata'ları — label/icon değiştiğinde tek yer burası.
  static const List<_TabMeta> _tabs = [
    _TabMeta(
        label: 'Ana Sayfa',
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded),
    _TabMeta(
        label: 'AI Koç',
        icon: Icons.auto_awesome_outlined,
        activeIcon: Icons.auto_awesome_rounded),
    _TabMeta(
        label: 'Uyku',
        icon: Icons.library_music_outlined,
        activeIcon: Icons.library_music_rounded),
    _TabMeta(
        label: 'Akademi',
        icon: Icons.school_outlined,
        activeIcon: Icons.school_rounded),
    _TabMeta(
        label: 'Ayarlar',
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = useState(0);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,

      // ── IndexedStack: sekme ağaçlarını canlı tutar ─────────────────────────
      body: IndexedStack(
        index: currentIndex.value,
        children: const [
          HomeScreen(),
          AiInsightScreen(),
          SleepLibraryScreen(),
          AcademyScreen(),
          SettingsScreen(),
        ],
      ),

      // ── BottomNavigationBar ────────────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        key: TutorialKeys.bottomNavKey,
        currentIndex: currentIndex.value,
        onTap: (i) => currentIndex.value = i,
        // Simetri: sabit tip + eşit font boyutu (ThemeData'da da ayarlandı)
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12.0,
        unselectedFontSize: 12.0,
        items: _tabs
            .map((t) => BottomNavigationBarItem(
                  icon: Icon(t.icon),
                  activeIcon: Icon(t.activeIcon),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}

/// Sekme metadata modeli — immutable.
final class _TabMeta {
  const _TabMeta({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
  final String label;
  final IconData icon;
  final IconData activeIcon;
}
