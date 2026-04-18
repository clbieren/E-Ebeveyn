import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:babytracker/core/constants/app_constants.dart';
import 'package:babytracker/features/child/providers/child_providers.dart';
import 'package:babytracker/features/event_log/data/models/event_log_model.dart';
import 'package:babytracker/features/event_log/providers/event_log_providers.dart';

/// Son aktiviteler — Realm [recentEventsProvider] stream ile anlık güncellenir.
///
/// Yatay renkli kutucuklar; iç içe scroll çakışması yok (tek yatay ListView).
class RecentEventsList extends ConsumerWidget {
  const RecentEventsList({super.key});

  static const int _kLimit = 8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(selectedChildProvider);
    final eventsAsync = ref.watch(recentEventsProvider(limit: _kLimit));

    if (child == null) return const SizedBox.shrink();

    return eventsAsync.when(
      loading: () => const _Skeleton(),
      error: (_, __) => const SizedBox.shrink(),
      data: (events) {
        if (events.isEmpty) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Text(
              'Henüz aktivite yok',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        return SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: events.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _ActivityTile(event: events[i]),
          ),
        );
      },
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.event});

  final EventLogModel event;

  static final DateFormat _timeFmt = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    final meta = EventMeta.resolve(event.eventType, event.subType);
    final time = _timeFmt.format(event.startTime.toLocal());
    final subtitle = meta.subLabel ?? _durationHint(event);

    return SizedBox(
      width: 112,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                meta.color.withValues(alpha: 0.35),
                meta.color.withValues(alpha: 0.14),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: meta.color.withValues(alpha: 0.65),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: meta.color.withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meta.emoji,
                style: const TextStyle(fontSize: 26, height: 1.1),
              ),
              const Spacer(),
              Text(
                meta.primaryLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String? _durationHint(EventLogModel e) {
    if (e.eventType != AppConstants.eventTypeSleep) return null;
    if (e.endTime == null) return 'Devam ediyor';
    final secs = e.endTime!.difference(e.startTime).inSeconds;
    if (secs <= 60) return null;
    final mins = e.endTime!.difference(e.startTime).inMinutes;
    if (mins < 60) return '$mins dk';
    final h = mins ~/ 60;
    final m = mins % 60;
    return m > 0 ? '${h}s ${m}dk' : '${h}s';
  }
}

// ── EventMeta ─────────────────────────────────────────────────────────────────

/// Event tipine ve alt tipine göre görsel metadata.
/// Hem kutucuklar hem QuickActionBar bu sınıfı kullanır — tek kaynak.
final class EventMeta {
  const EventMeta({
    required this.emoji,
    required this.primaryLabel,
    required this.color,
    this.subLabel,
  });

  final String emoji;
  final String primaryLabel;
  final String? subLabel;
  final Color color;

  factory EventMeta.resolve(String eventType, [String? subType]) {
    return switch (eventType) {
      AppConstants.eventTypeSleep => const EventMeta(
          emoji: '💤',
          primaryLabel: 'Uyku',
          color: Color(0xFFB39DDB),
        ),
      AppConstants.eventTypeFeed => EventMeta(
          emoji: '🍼',
          primaryLabel: 'Beslenme',
          color: const Color(0xFF80CBC4),
          subLabel: switch (subType) {
            AppConstants.feedSubBreastMilk => 'Anne sütü',
            AppConstants.feedSubFormula => 'Mama',
            _ => null,
          },
        ),
      AppConstants.eventTypeDiaper => EventMeta(
          emoji: '🧻',
          primaryLabel: 'Bez',
          color: const Color(0xFFFFCC80),
          subLabel: switch (subType) {
            AppConstants.diaperSubWet => 'Islak',
            AppConstants.diaperSubDirty => 'Kirli',
            AppConstants.diaperSubClean => 'Temiz',
            _ => null,
          },
        ),
      _ => const EventMeta(
          emoji: '📋',
          primaryLabel: 'Aktivite',
          color: Color(0xFF9E9E9E),
        ),
    };
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, __) => Container(
          width: 112,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant),
          ),
        ),
      ),
    );
  }
}
