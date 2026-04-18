import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shimmer_skeleton.dart';
import '../providers/reminder_provider.dart';
import 'widgets/add_reminder_bottom_sheet.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  static final DateFormat _dtFmt = DateFormat('dd.MM HH:mm');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminderState = ref.watch(reminderProvider);

    ref.listen<AsyncValue<List<ReminderItem>>>(reminderProvider, (_, next) {
      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  error is Exception
                      ? error.toString().replaceFirst('Exception: ', '')
                      : 'Hatırlatıcı işlemi başarısız. Lütfen tekrar deneyin.',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Akilli Hatirlaticilar'),
      ),
      body: reminderState.when(
        loading: () => const _RemindersSkeleton(),
        error: (_, __) => const _RemindersError(),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Henuz aktif hatirlatici yok.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.tertiary),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x332196F3),
                      blurRadius: 10,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active_rounded,
                        color: AppColors.tertiary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _dtFmt.format(item.scheduledAt),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.error),
                      onPressed: () {
                        ref
                            .read(reminderProvider.notifier)
                            .removeReminder(item.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (_) => const AddReminderBottomSheet(),
          );
        },
        child: const Icon(Icons.add_alarm_rounded),
      ),
    );
  }
}

class _RemindersSkeleton extends StatelessWidget {
  const _RemindersSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Row(
          children: [
            ShimmerSkeleton(
                height: 20,
                width: 20,
                borderRadius: BorderRadius.all(Radius.circular(6))),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerSkeleton(height: 12, width: 180),
                  SizedBox(height: 8),
                  ShimmerSkeleton(height: 10, width: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RemindersError extends ConsumerWidget {
  const _RemindersError();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 34),
            const SizedBox(height: 10),
            const Text(
              'Hatırlatıcılar yüklenemedi.',
              style: TextStyle(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => ref.read(reminderProvider.notifier).load(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }
}
