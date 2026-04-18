import 'package:realm/realm.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../event_log/data/models/event_log_model.dart';

class SleepSummary {
  const SleepSummary({
    required this.totalDuration,
  });

  final Duration totalDuration;
}

class FeedSummary {
  const FeedSummary({
    required this.totalCount,
    required this.breastMilkCount,
    required this.formulaCount,
  });

  final int totalCount;
  final int breastMilkCount;
  final int formulaCount;
}

class DiaperSummary {
  const DiaperSummary({
    required this.totalCount,
    required this.dirtyCount,
    required this.wetCount,
    required this.cleanCount,
  });

  final int totalCount;
  final int dirtyCount;
  final int wetCount;
  final int cleanCount;
}

class DailyMetric {
  const DailyMetric({
    required this.dayLabel,
    required this.value,
  });

  final String dayLabel;
  final double value;
}

final class ReportsRepository {
  const ReportsRepository(this._realm);

  final Realm _realm;

  RealmResults<EventLogModel> watchRecentEvents(ObjectId childId) {
    final since = DateTime.now().toUtc().subtract(const Duration(days: 7));
    return _realm.all<EventLogModel>().query(
      r'child_id == $0 AND start_time >= $1 SORT(start_time ASC)',
      [childId, since],
    );
  }

  SleepSummary getTodaySleepTotal(List<EventLogModel> events) {
    final dayStart = _dayStartUtc(DateTime.now().toUtc());
    final dayEnd = dayStart.add(const Duration(days: 1));

    var total = Duration.zero;
    for (final event in events) {
      if (event.eventType != AppConstants.eventTypeSleep) continue;
      if (event.startTime.isBefore(dayStart) ||
          !event.startTime.isBefore(dayEnd)) {
        continue;
      }
      final end = event.endTime?.toUtc() ?? DateTime.now().toUtc();
      if (end.isAfter(event.startTime)) {
        total += end.difference(event.startTime.toUtc());
      }
    }

    return SleepSummary(totalDuration: total);
  }

  FeedSummary getTodayFeedCount(List<EventLogModel> events) {
    final dayStart = _dayStartUtc(DateTime.now().toUtc());
    final dayEnd = dayStart.add(const Duration(days: 1));

    var total = 0;
    var breast = 0;
    var formula = 0;

    for (final event in events) {
      if (event.eventType != AppConstants.eventTypeFeed) continue;
      if (event.startTime.isBefore(dayStart) ||
          !event.startTime.isBefore(dayEnd)) {
        continue;
      }
      total++;
      if (event.subType == AppConstants.feedSubBreastMilk) breast++;
      if (event.subType == AppConstants.feedSubFormula) formula++;
    }

    return FeedSummary(
      totalCount: total,
      breastMilkCount: breast,
      formulaCount: formula,
    );
  }

  DiaperSummary getTodayDiaperCount(List<EventLogModel> events) {
    final dayStart = _dayStartUtc(DateTime.now().toUtc());
    final dayEnd = dayStart.add(const Duration(days: 1));

    var total = 0;
    var dirty = 0;
    var wet = 0;
    var clean = 0;

    for (final event in events) {
      if (event.eventType != AppConstants.eventTypeDiaper) continue;
      if (event.startTime.isBefore(dayStart) ||
          !event.startTime.isBefore(dayEnd)) {
        continue;
      }
      total++;
      if (event.subType == AppConstants.diaperSubDirty) dirty++;
      if (event.subType == AppConstants.diaperSubWet) wet++;
      if (event.subType == AppConstants.diaperSubClean) clean++;
    }

    return DiaperSummary(
      totalCount: total,
      dirtyCount: dirty,
      wetCount: wet,
      cleanCount: clean,
    );
  }

  List<DailyMetric> getWeeklySleepHours(List<EventLogModel> events) {
    final now = DateTime.now().toUtc();
    final start = _dayStartUtc(now).subtract(const Duration(days: 6));
    final values = List<double>.filled(7, 0);

    for (final event in events) {
      if (event.eventType != AppConstants.eventTypeSleep) continue;
      if (event.startTime.isBefore(start)) continue;

      final index = event.startTime.toUtc().difference(start).inDays;
      if (index < 0 || index > 6) continue;
      final end = event.endTime?.toUtc() ?? now;
      final duration = end.isAfter(event.startTime)
          ? end.difference(event.startTime.toUtc())
          : Duration.zero;
      values[index] += duration.inMinutes / 60.0;
    }

    return _weeklyLabels(start, values);
  }

  List<DailyMetric> getWeeklyFeedFrequency(List<EventLogModel> events) {
    final now = DateTime.now().toUtc();
    final start = _dayStartUtc(now).subtract(const Duration(days: 6));
    final values = List<double>.filled(7, 0);

    for (final event in events) {
      if (event.eventType != AppConstants.eventTypeFeed) continue;
      if (event.startTime.isBefore(start)) continue;

      final index = event.startTime.toUtc().difference(start).inDays;
      if (index < 0 || index > 6) continue;
      values[index] += 1;
    }

    return _weeklyLabels(start, values);
  }

  List<DailyMetric> _weeklyLabels(DateTime start, List<double> values) {
    const labels = ['Pzt', 'Sal', 'Car', 'Per', 'Cum', 'Cmt', 'Paz'];
    final items = <DailyMetric>[];

    for (var i = 0; i < 7; i++) {
      final day = start.add(Duration(days: i));
      final label = labels[day.weekday - 1];
      items.add(DailyMetric(dayLabel: label, value: values[i]));
    }
    return items;
  }

  DateTime _dayStartUtc(DateTime dateTime) {
    return DateTime.utc(dateTime.year, dateTime.month, dateTime.day);
  }
}
