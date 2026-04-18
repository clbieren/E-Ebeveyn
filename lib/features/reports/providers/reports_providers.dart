import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/db/providers/realm_provider.dart';
import '../../child/providers/child_providers.dart';
import '../../event_log/data/models/event_log_model.dart';
import '../data/repositories/reports_repository.dart';

class DailyReportBundle {
  const DailyReportBundle({
    required this.sleep,
    required this.feed,
    required this.diaper,
    required this.weeklySleep,
    required this.weeklyFeed,
  });

  final SleepSummary sleep;
  final FeedSummary feed;
  final DiaperSummary diaper;
  final List<DailyMetric> weeklySleep;
  final List<DailyMetric> weeklyFeed;
}

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepository(ref.watch(realmProvider));
});

final dailyReportBundleProvider =
    StreamProvider<DailyReportBundle>((ref) async* {
  final childId = ref.watch(selectedChildIdProvider);
  if (childId == null) {
    yield const DailyReportBundle(
      sleep: SleepSummary(totalDuration: Duration.zero),
      feed: FeedSummary(totalCount: 0, breastMilkCount: 0, formulaCount: 0),
      diaper: DiaperSummary(
          totalCount: 0, dirtyCount: 0, wetCount: 0, cleanCount: 0),
      weeklySleep: [],
      weeklyFeed: [],
    );
    return;
  }

  final repository = ref.watch(reportsRepositoryProvider);
  final results = repository.watchRecentEvents(childId);

  DailyReportBundle pack(List<EventLogModel> events) {
    return DailyReportBundle(
      sleep: repository.getTodaySleepTotal(events),
      feed: repository.getTodayFeedCount(events),
      diaper: repository.getTodayDiaperCount(events),
      weeklySleep: repository.getWeeklySleepHours(events),
      weeklyFeed: repository.getWeeklyFeedFrequency(events),
    );
  }

  yield pack(results.toList());
  await for (final c in results.changes) {
    yield pack(c.results.toList());
  }
});
