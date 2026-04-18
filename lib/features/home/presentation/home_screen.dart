import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:babytracker/core/auth/auth_provider.dart';
import 'package:babytracker/core/constants/app_constants.dart';
import 'package:babytracker/features/child/data/models/child_model.dart';
import 'package:babytracker/features/child/providers/child_providers.dart';
import 'package:babytracker/features/event_log/providers/event_log_providers.dart';
import 'package:babytracker/features/home/presentation/widgets/child_selector_bar.dart';
import 'package:babytracker/features/home/presentation/widgets/recent_events_list.dart';
import 'package:babytracker/features/onboarding/presentation/onboarding_screen.dart';
import 'package:babytracker/features/vaccination/presentation/vaccination_screen.dart';
import 'package:babytracker/features/reports/providers/reports_providers.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:babytracker/core/sync/providers/sync_providers.dart';
import 'package:babytracker/features/home/providers/tutorial_provider.dart';
import 'package:babytracker/features/home/providers/tutorial_keys.dart';
import 'package:babytracker/features/home/presentation/widgets/tutorial_service.dart';

/// Ana ekran.
///
/// LAYOUT KURALI — Taşma Önleyici:
///
/// ```
/// Scaffold
/// └── SingleChildScrollView
///     └── Column
///         ├── ChildSelectorBar
///         ├── Divider
///         ├── ChildHeader
///         ├── QuickActionBar
///         ├── _SectionHeader
///         └── RecentEventsList       ← yatay renkli kutucuklar (Realm stream)
/// ```
class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    final hasShownTutorial = ref.watch(tutorialProvider);

    useEffect(() {
      if (!hasShownTutorial) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Delaying slightly to ensure layout is fully done
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!context.mounted) return;
            HomeTutorialTargets.showTutorial(
              context: context,
              onFinish: () {
                ref.read(tutorialProvider.notifier).markAsShown();
              },
            );
          });
        });
      }
      return null;
    }, [hasShownTutorial]);

    final textTheme = Theme.of(context).textTheme;
    final selectedChild = ref.watch(selectedChildProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: Text(
          'E-Ebeveyn',
          style: textTheme.titleLarge?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          Container(
            key: TutorialKeys.syncButtonKey,
            child: const _SyncAction(),
          ),
          // Logout — auth_provider'daki güvenli sırayla çalışır
          PopupMenuButton<_HomeMenu>(
            icon: Icon(Icons.more_vert_rounded,
                color: cs.onSurfaceVariant, size: 22),
            color: cs.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: cs.outline),
            ),
            onSelected: (action) async {
              if (action == _HomeMenu.signOut) {
                // Güvenli logout: önce context kontrolü, sonra çağrı
                if (!context.mounted) return;
                await ref.read(authNotifierProvider.notifier).signOut();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: _HomeMenu.signOut,
                child: Row(children: [
                  Icon(Icons.logout_rounded,
                      color: cs.onSurfaceVariant, size: 18),
                  const SizedBox(width: 10),
                  Text('Çıkış Yap',
                      style:
                          textTheme.bodyMedium?.copyWith(color: cs.onSurface)),
                ]),
              ),
            ],
          ),
        ],
      ),

      // ── Gövde: dikey Column, taşma yok ─────────────────────────────────────
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                key: TutorialKeys.topSectionKey,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: _ChildProfileCard(
                  child: selectedChild,
                  onOpenVaccination: selectedChild == null
                      ? null
                      : () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => const VaccinationScreen(),
                            ),
                          );
                        },
                ),
              ),

              // 1. Çocuk seçici — yatay scroll, sabit 72dp
              const ChildSelectorBar(),

              const Divider(height: 1),

              Padding(
                key: TutorialKeys.quickActionsKey,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: _QuickActionsRow(selectedChild: selectedChild),
              ),

              // 4. Grafik
              Padding(
                key: TutorialKeys.chartSectionKey,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
                child: const _WeeklySleepFeedBarChart(),
              ),

              // 5. Bölüm başlığı
              _SectionHeader(
                title: 'SON AKTİVİTELER',
                textTheme: textTheme,
                cs: cs,
              ),

              // 6. Aktivite listesi — parent scroll içinde, kendi scroll'u kapalı
              const RecentEventsList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildProfileCard extends StatelessWidget {
  const _ChildProfileCard({
    required this.child,
    this.onOpenVaccination,
  });

  final ChildModel? child;
  final VoidCallback? onOpenVaccination;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (child == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Text(
          'Çocuk Profili Bulunamadı',
          style: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      );
    }

    final birthDate = child!.birthDate;
    final now = DateTime.now();
    final days = now.difference(birthDate).inDays;
    final ageLabel = days < 0 ? '0 gün' : '$days gün';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Icon(Icons.child_care_rounded, color: cs.onSurface),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child!.name,
                  style: textTheme.titleMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ageLabel,
                  style: textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (onOpenVaccination != null)
            IconButton(
              tooltip: 'Aşı takvimi',
              onPressed: onOpenVaccination,
              icon: Icon(Icons.vaccines_rounded, color: cs.primary),
            ),
        ],
      ),
    );
  }
}

enum _HomeMenu { signOut }

class _SyncAction extends ConsumerWidget {
  const _SyncAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.sync_rounded, size: 22),
          color: cs.onSurfaceVariant,
          onPressed: () async {
            try {
              await ref
                  .read(syncOrchestratorProvider.notifier)
                  .triggerManualSync();
              final syncState = ref.read(syncOrchestratorProvider);
              final isFamilyMissing = (syncState.message ?? '')
                  .toLowerCase()
                  .contains('family id bulunamadi');
              if (isFamilyMissing && context.mounted) {
                await Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => const OnboardingScreen(),
                  ),
                );
                return;
              }
              ref.invalidate(recentEventsProvider());
              ref.read(eventStateRefreshProvider).refreshAllEventStates();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Senkronize edildi!'),
                  ),
                );
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text('Hata: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
            }
          },
          tooltip: 'Senkronize Et',
        ),
      ],
    );
  }
}

class _QuickActionsRow extends ConsumerWidget {
  const _QuickActionsRow({required this.selectedChild});

  final ChildModel? selectedChild;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final actions = ref.read(activityActionsProvider);

    ButtonStyle style = FilledButton.styleFrom(
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      side: BorderSide(color: cs.outlineVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(vertical: 14),
    );

    final disabled = selectedChild == null;
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            style: style,
            onPressed: disabled
                ? null
                : () async {
                    await _showSleepDurationSheet(context, actions);
                  },
            child: const Text('Uyku'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton(
            style: style,
            onPressed: disabled
                ? null
                : () async {
                    await _showFeedBottomSheet(context, actions);
                  },
            child: const Text('Beslenme'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton(
            style: style,
            onPressed: disabled
                ? null
                : () async {
                    await _showDiaperBottomSheet(context, actions);
                  },
            child: const Text('Bez'),
          ),
        ),
      ],
    );
  }
}

Future<void> _showSleepDurationSheet(
  BuildContext context,
  ActivityActions actions,
) async {
  final cs = Theme.of(context).colorScheme;
  var hours = 1;
  var quarterIndex = 0; // 0,1,2,3 → 0,15,30,45 dk

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: cs.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setModalState) {
          final minutes = quarterIndex * 15;
          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Uyku süresi',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bebeğin son uyku süresini seçin (bitiş: şimdi).',
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Saat',
                              style: Theme.of(ctx).textTheme.labelMedium),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<int>(
                            value: hours,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: List.generate(
                              13,
                              (i) => DropdownMenuItem(
                                value: i,
                                child: Text('$i saat'),
                              ),
                            ),
                            onChanged: (v) {
                              if (v == null) return;
                              setModalState(() => hours = v);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dakika',
                              style: Theme.of(ctx).textTheme.labelMedium),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<int>(
                            value: quarterIndex,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: const [
                              DropdownMenuItem(value: 0, child: Text('0 dk')),
                              DropdownMenuItem(value: 1, child: Text('15 dk')),
                              DropdownMenuItem(value: 2, child: Text('30 dk')),
                              DropdownMenuItem(value: 3, child: Text('45 dk')),
                            ],
                            onChanged: (v) {
                              if (v == null) return;
                              setModalState(() => quarterIndex = v);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: hours == 0 && minutes == 0
                      ? null
                      : () {
                          final d = Duration(hours: hours, minutes: minutes);
                          actions.logSleepDuration(d);
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Uyku kaydedildi: $hours sa $minutes dk',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                        },
                  child: const Text('Kaydet'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Future<void> _showFeedBottomSheet(
  BuildContext context,
  ActivityActions actions,
) async {
  final cs = Theme.of(context).colorScheme;
  final formKey = GlobalKey<FormState>();
  final mlController = TextEditingController();
  String selectedSubType = AppConstants.feedSubBreastMilk;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: cs.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Beslenme Detayı',
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: AppConstants.feedSubBreastMilk,
                        label: Text('Anne Sütü'),
                      ),
                      ButtonSegment(
                        value: AppConstants.feedSubFormula,
                        label: Text('Mama'),
                      ),
                      ButtonSegment(
                        value: 'solid_food',
                        label: Text('Ek Gıda'),
                      ),
                    ],
                    selected: {selectedSubType},
                    onSelectionChanged: (values) {
                      setModalState(() => selectedSubType = values.first);
                    },
                  ),
                  if (selectedSubType != AppConstants.feedSubBreastMilk) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: mlController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Miktar (ml)',
                        hintText: 'Örn: 120',
                      ),
                      validator: (value) {
                        if (selectedSubType == AppConstants.feedSubBreastMilk) {
                          return null;
                        }
                        if (value == null || value.trim().isEmpty) {
                          return 'Miktar girin';
                        }
                        final parsed = int.tryParse(value.trim());
                        if (parsed == null || parsed <= 0)
                          return 'Geçerli ml girin';
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        final amount =
                            selectedSubType == AppConstants.feedSubBreastMilk
                                ? null
                                : int.tryParse(mlController.text.trim());
                        actions.logFeed(
                          subType: selectedSubType,
                          amountMl: amount,
                        );
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                              content: Text('Beslenme kaydı eklendi'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                      },
                      child: const Text('Kaydet'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> _showDiaperBottomSheet(
  BuildContext context,
  ActivityActions actions,
) async {
  final cs = Theme.of(context).colorScheme;
  String selectedSubType = AppConstants.diaperSubWet;

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: cs.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bez Detayı',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: AppConstants.diaperSubWet,
                      label: Text('Sadece Çiş'),
                    ),
                    ButtonSegment(
                      value: AppConstants.diaperSubDirty,
                      label: Text('Sadece Kaka'),
                    ),
                    ButtonSegment(
                      value: AppConstants.diaperSubClean,
                      label: Text('İkisi de'),
                    ),
                  ],
                  selected: {selectedSubType},
                  onSelectionChanged: (values) {
                    setModalState(() => selectedSubType = values.first);
                  },
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      actions.logDiaper(subType: selectedSubType);
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text('Bez kaydı eklendi'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                    },
                    child: const Text('Kaydet'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.textTheme,
    required this.cs,
  });

  final String title;
  final TextTheme textTheme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
      child: Text(
        title,
        style: textTheme.labelMedium?.copyWith(
          color: cs.onSurfaceVariant,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _WeeklySleepFeedBarChart extends ConsumerWidget {
  const _WeeklySleepFeedBarChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bundleAsync = ref.watch(dailyReportBundleProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Son 7 Günlük Uyku/Beslenme',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 160,
            child: bundleAsync.when(
              loading: () => Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(cs.primary),
                  ),
                ),
              ),
              error: (_, __) => Center(
                child: Text(
                  'Grafik yüklenemedi',
                  style:
                      textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
              data: (bundle) => BarChart(_barData(context, bundle)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _LegendDot(color: cs.primary, label: 'Uyku (saat)'),
              const SizedBox(width: 12),
              _LegendDot(color: cs.tertiary, label: 'Beslenme (adet)'),
            ],
          ),
        ],
      ),
    );
  }

  BarChartData _barData(BuildContext context, DailyReportBundle bundle) {
    final cs = Theme.of(context).colorScheme;
    final sleep = bundle.weeklySleep;
    final feed = bundle.weeklyFeed;

    final maxY = [
      ...sleep.map((e) => e.value),
      ...feed.map((e) => e.value),
      1.0,
    ].reduce((a, b) => a > b ? a : b);

    final groups = List.generate(7, (i) {
      final s = i < sleep.length ? sleep[i] : null;
      final f = i < feed.length ? feed[i] : null;
      return BarChartGroupData(
        x: i,
        barsSpace: 6,
        barRods: [
          BarChartRodData(
            toY: (s?.value ?? 0).clamp(0, 9999).toDouble(),
            width: 10,
            borderRadius: BorderRadius.circular(6),
            color: cs.primary,
          ),
          BarChartRodData(
            toY: (f?.value ?? 0).clamp(0, 9999).toDouble(),
            width: 10,
            borderRadius: BorderRadius.circular(6),
            color: cs.tertiary,
          ),
        ],
      );
    });

    return BarChartData(
      maxY: (maxY <= 0 ? 1 : maxY * 1.25),
      barGroups: groups,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => FlLine(
          color: cs.outlineVariant,
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: (maxY / 2).clamp(1, 9999),
            getTitlesWidget: (value, meta) => Text(
              value == meta.max ? '' : value.toStringAsFixed(0),
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10),
            ),
          ),
        ),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final i = value.toInt();
              final label = i >= 0 && i < sleep.length ? sleep[i].dayLabel : '';
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  label,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10),
                ),
              );
            },
          ),
        ),
      ),
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final day = groupIndex >= 0 && groupIndex < sleep.length
                ? sleep[groupIndex].dayLabel
                : '';
            final label = rodIndex == 0 ? 'Uyku' : 'Beslenme';
            return BarTooltipItem(
              '$day\n$label: ${rod.toY.toStringAsFixed(rodIndex == 0 ? 1 : 0)}',
              const TextStyle(fontWeight: FontWeight.w600),
            );
          },
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}
