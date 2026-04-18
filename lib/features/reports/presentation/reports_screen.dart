import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/shimmer_skeleton.dart';
import '../providers/reports_providers.dart';
import 'widgets/daily_summary_card.dart';
import 'widgets/weekly_chart_widget.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(dailyReportBundleProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Raporlar'),
      ),
      body: SafeArea(
        child: reportAsync.when(
          loading: () => const _ReportsSkeleton(),
          error: (_, __) => const Center(
            child: Text(
              'Raporlar yuklenemedi',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
          data: (report) {
            final sleep = report.sleep.totalDuration;
            final sleepLabel = '${sleep.inHours}s ${sleep.inMinutes % 60}dk';
            final hasAnyData = report.feed.totalCount > 0 ||
                report.diaper.totalCount > 0 ||
                report.sleep.totalDuration > Duration.zero;

            if (!hasAnyData) {
              return const EmptyStateWidget(
                icon: Icons.insights_rounded,
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.22,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    DailySummaryCard(
                      title: 'Uyku',
                      value: sleepLabel,
                      subtitle: 'Bugun toplam uyku',
                      accent: AppColors.primary,
                    ),
                    DailySummaryCard(
                      title: 'Beslenme',
                      value: '${report.feed.totalCount}',
                      subtitle:
                          '${report.feed.breastMilkCount} Anne Sutu, ${report.feed.formulaCount} Mama',
                      accent: AppColors.secondary,
                    ),
                    DailySummaryCard(
                      title: 'Bez',
                      value: '${report.diaper.totalCount}',
                      subtitle:
                          '${report.diaper.dirtyCount} Kirli, ${report.diaper.wetCount} Islak',
                      accent: AppColors.tertiary,
                    ),
                    DailySummaryCard(
                      title: 'Temiz',
                      value: '${report.diaper.cleanCount}',
                      subtitle: 'Bugun temiz degisim',
                      accent: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                WeeklyChartWidget(
                  title: 'Son 7 Gun Uyku (Saat)',
                  items: report.weeklySleep,
                  accent: AppColors.primary,
                ),
                const SizedBox(height: 12),
                WeeklyChartWidget(
                  title: 'Son 7 Gun Beslenme (Adet)',
                  items: report.weeklyFeed,
                  accent: AppColors.secondary,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReportsSkeleton extends StatelessWidget {
  const _ReportsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.22,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            _MetricCardSkeleton(),
            _MetricCardSkeleton(),
            _MetricCardSkeleton(),
            _MetricCardSkeleton(),
          ],
        ),
        const SizedBox(height: 16),
        const ShimmerSkeleton(
            height: 180, borderRadius: BorderRadius.all(Radius.circular(16))),
        const SizedBox(height: 12),
        const ShimmerSkeleton(
            height: 180, borderRadius: BorderRadius.all(Radius.circular(16))),
      ],
    );
  }
}

class _MetricCardSkeleton extends StatelessWidget {
  const _MetricCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerSkeleton(height: 12, width: 80),
          Spacer(),
          ShimmerSkeleton(height: 18, width: 90),
          SizedBox(height: 8),
          ShimmerSkeleton(height: 10, width: 120),
        ],
      ),
    );
  }
}
