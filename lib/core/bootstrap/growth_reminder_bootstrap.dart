import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../notifications/growth_measurement_scheduler.dart';
import '../../features/child/providers/child_providers.dart';
import '../../features/ai_coach/providers/ai_coach_provider.dart';

/// Çocuk listesi yüklendiğinde boy/kilo hatırlatmalarını yeniden planlar
/// ve arka plan proaktif yapay zeka denetimini gizlice (non-blocking) tetikler.
class GrowthReminderBootstrap extends HookConsumerWidget {
  const GrowthReminderBootstrap({super.key, required this.body});

  final Widget body;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncChildren = ref.watch(childrenProvider);

    useEffect(() {
      asyncChildren.whenData((list) {
        GrowthMeasurementScheduler.instance.rescheduleAll(list);

        // Gizli & proaktif AI anomali denetimini fırlat (await edilmez).
        ref.read(aiCoachProvider.notifier).runProactiveAnalysisInBackground();
      });
      return null;
    }, [asyncChildren]);

    return body;
  }
}
