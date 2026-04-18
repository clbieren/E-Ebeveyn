import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../child/data/models/child_model.dart';
import '../../child/providers/child_providers.dart';
import '../data/vaccination_due_helper.dart';
import '../data/vaccination_schedule.dart';
import '../providers/vaccination_providers.dart';

/// Seçili çocuk için dinamik aşı takvimi ve Supabase `child_vaccine_logs` tamamlama.
class VaccinationScreen extends ConsumerWidget {
  const VaccinationScreen({super.key});

  static final DateFormat _dateFmt = DateFormat.yMMMd('tr');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(selectedChildProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (child == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Aşı takvimi')),
        body: Center(
          child: Text(
            'Önce ana ekrandan bir çocuk seçin.',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      );
    }

    final asyncKeys = ref.watch(completedVaccineKeysProvider(child.syncId));

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: Text(
          'Aşı takvimi — ${child.name}',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: asyncKeys.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Liste yüklenemedi. Supabase\'de child_vaccine_logs tablosunu '
              'oluşturduğunuzdan emin olun.\n\n$e',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (completed) {
          final birth = child.birthDate.toLocal();
          final today = DateTime.now();
          final ordered = VaccinationDueHelper.sortedByDueDate(birth);

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: ordered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) {
              final e = ordered[i];
              final due = VaccinationDueHelper.dueCalendarDate(
                birth,
                e.monthAge,
              );
              final isDone = completed.contains(e.key);
              final st = VaccinationDueHelper.statusFor(
                today,
                due,
                isDone,
              );

              final accent = switch (st) {
                VaccineDueUiStatus.completed => cs.outline,
                VaccineDueUiStatus.overdue => cs.error,
                VaccineDueUiStatus.dueSoon => cs.primary,
                VaccineDueUiStatus.upcoming => cs.tertiary,
              };

              return Material(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: isDone
                      ? null
                      : () => _submitVaccineToggle(
                            context,
                            ref,
                            child,
                            e,
                          ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: Checkbox(
                            value: isDone,
                            onChanged: isDone
                                ? null
                                : (_) => _submitVaccineToggle(
                                      context,
                                      ref,
                                      child,
                                      e,
                                    ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.label,
                                style: tt.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Plan: ${_dateFmt.format(due)} · '
                                '${VaccinationDueHelper.statusLabelTr(st)}',
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${e.monthAge}. ay',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

Future<void> _submitVaccineToggle(
  BuildContext context,
  WidgetRef ref,
  ChildModel child,
  VaccineScheduleEntry e,
) async {
  try {
    await ref.read(vaccinationRepositoryProvider).markCompleted(
          child: child,
          vaccineKey: e.key,
        );
    ref.invalidate(completedVaccineKeysProvider(child.syncId));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kaydedildi: ${e.label}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } catch (err) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kayıt hatası: $err'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
