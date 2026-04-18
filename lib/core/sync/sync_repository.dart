import 'package:realm/realm.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/child/data/models/child_model.dart';
import '../../features/event_log/data/models/event_log_model.dart';

class SyncResult {
  const SyncResult({
    this.pushedCount = 0,
    this.pulledCount = 0,
    this.errorMessage,
  });

  final int pushedCount;
  final int pulledCount;
  final String? errorMessage;
}

final class SyncException implements Exception {
  const SyncException(this.userMessage);
  final String userMessage;
  @override
  String toString() => userMessage;
}

final class SyncRepository {
  SyncRepository(this._realm, this._supabase);

  final Realm _realm;
  final SupabaseClient _supabase;

  DateTime _lastSyncAt = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  Future<SyncResult> sync({
    required String userId,
    required bool isOnline,
  }) async {
    if (!isOnline) {
      return const SyncResult();
    }

    try {
      final familyId = await _getFamilyId(userId);
      final pushed = await _push(userId: userId, familyId: familyId);
      final pulled = await _pull(
        userId: userId,
        familyId: familyId,
        since: _lastSyncAt,
      );
      _lastSyncAt = DateTime.now().toUtc();

      return SyncResult(
        pushedCount: pushed,
        pulledCount: pulled,
      );
    } catch (e) {
      throw SyncException(
        'Senkronizasyon sırasında hata oluştu. (${e.runtimeType})',
      );
    }
  }

  Future<SyncResult> performFullSync({
    required String userId,
    required bool isOnline,
  }) async {
    if (!isOnline) return const SyncResult();

    try {
      final familyId = await _getFamilyId(userId);
      final pulled = await _pull(
        userId: userId,
        familyId: familyId,
        since: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      );
      _lastSyncAt = DateTime.now().toUtc();
      return SyncResult(pulledCount: pulled);
    } catch (e) {
      throw SyncException(
        'Tam senkronizasyon başarısız. (${e.runtimeType})',
      );
    }
  }

  Future<int> _push({
    required String userId,
    required String familyId,
  }) async {
    var pushedCount = 0;

    final unsyncedEvents =
        _realm.all<EventLogModel>().query(r'is_synced == false').toList();

    if (unsyncedEvents.isNotEmpty) {
      final payload = unsyncedEvents.map((event) {
        final child = _realm.find<ChildModel>(event.childId);
        return <String, dynamic>{
          'id': event.syncId,
          'user_id': userId,
          'family_id': familyId,
          'child_id': child?.syncId,
          'event_type': event.eventType,
          'sub_type': event.subType,
          'start_time': event.startTime.toIso8601String(),
          'end_time': event.endTime?.toIso8601String(),
          'note': event.note,
          'updated_at': event.updatedAt.toIso8601String(),
          'created_at': event.createdAt.toIso8601String(),
        };
      }).toList();

      await _supabase.from('event_logs').upsert(payload);

      _realm.write(() {
        for (final event in unsyncedEvents) {
          event.isSynced = true;
        }
      });

      pushedCount += unsyncedEvents.length;
    }

    final unsyncedChildren =
        _realm.all<ChildModel>().query(r'is_synced == false').toList();

    if (unsyncedChildren.isNotEmpty) {
      final payload = unsyncedChildren
          .map(
            (child) => <String, dynamic>{
              'id': child.syncId,
              'user_id': userId,
              'family_id': familyId,
              'name': child.name,
              'gender': child.gender,
              'height': child.height,
              'weight': child.weight,
              'birth_date': child.birthDate.toIso8601String(),
              'updated_at': child.updatedAt.toIso8601String(),
              'created_at': child.createdAt.toIso8601String(),
            },
          )
          .toList();

      await _supabase.from('children').upsert(payload);
      _realm.write(() {
        for (final child in unsyncedChildren) {
          child.isSynced = true;
        }
      });
      pushedCount += unsyncedChildren.length;
    }

    return pushedCount;
  }

  Future<int> _pull({
    required String userId,
    required String familyId,
    required DateTime since,
  }) async {
    var pulledCount = 0;

    final childrenQuery = _supabase.from('children').select();
    final remoteChildren = await childrenQuery
        .eq('family_id', familyId)
        .gt('updated_at', since.toIso8601String());

    pulledCount += _mergeChildren(remoteChildren);

    final eventsQuery = _supabase.from('event_logs').select();
    final remoteEvents = await eventsQuery
        .eq('family_id', familyId)
        .gt('updated_at', since.toIso8601String());

    pulledCount += _mergeEvents(remoteEvents);
    return pulledCount;
  }

  int _mergeChildren(List<dynamic> rows) {
    var merged = 0;

    _realm.write(() {
      for (final row in rows) {
        final map = row as Map<String, dynamic>;
        final syncId = map['id'] as String?;
        if (syncId == null || syncId.isEmpty) continue;

        final remoteUpdatedAt = _dateTimeOrEpoch(map['updated_at']);
        final local = _realm
            .all<ChildModel>()
            .query(r'sync_id == $0', [syncId]).firstOrNull;

        if (local == null) {
          _realm.add(
            ChildModel(
              ObjectId(),
              syncId,
              (map['name'] as String?) ?? '',
              (map['gender'] as String?) ?? 'unknown',
              (map['height'] as num?)?.toDouble() ?? 0,
              (map['weight'] as num?)?.toDouble() ?? 0,
              _dateTimeOrEpoch(map['birth_date']),
              _dateTimeOrEpoch(map['created_at']),
              remoteUpdatedAt,
              isSynced: true,
            ),
            update: true,
          );
          merged++;
          continue;
        }

        // latest-wins: sadece remote daha yeniyse locale uygula.
        if (remoteUpdatedAt.isAfter(local.updatedAt)) {
          local
            ..name = (map['name'] as String?) ?? local.name
            ..gender = (map['gender'] as String?) ?? local.gender
            ..height = (map['height'] as num?)?.toDouble() ?? local.height
            ..weight = (map['weight'] as num?)?.toDouble() ?? local.weight
            ..birthDate = _dateTimeOrEpoch(map['birth_date'])
            ..updatedAt = remoteUpdatedAt
            ..isSynced = true;
          merged++;
        }
      }
    });

    return merged;
  }

  int _mergeEvents(List<dynamic> rows) {
    var merged = 0;

    _realm.write(() {
      for (final row in rows) {
        final map = row as Map<String, dynamic>;
        final syncId = map['id'] as String?;
        final childSyncId = map['child_id'] as String?;
        if (syncId == null || syncId.isEmpty || childSyncId == null) continue;

        final localChild = _realm
            .all<ChildModel>()
            .query(r'sync_id == $0', [childSyncId]).firstOrNull;
        if (localChild == null) {
          continue;
        }

        final remoteUpdatedAt = _dateTimeOrEpoch(map['updated_at']);
        final local = _realm
            .all<EventLogModel>()
            .query(r'sync_id == $0', [syncId]).firstOrNull;

        if (local == null) {
          _realm.add(
            EventLogModel(
              ObjectId(),
              syncId,
              localChild.id,
              (map['event_type'] as String?) ?? '',
              _dateTimeOrEpoch(map['start_time']),
              true,
              _dateTimeOrEpoch(map['created_at']),
              remoteUpdatedAt,
              subType: map['sub_type'] as String?,
              endTime: _dateTimeOrNull(map['end_time']),
              note: map['note'] as String?,
            ),
            update: true,
          );
          merged++;
          continue;
        }

        if (remoteUpdatedAt.isAfter(local.updatedAt)) {
          local
            ..childId = localChild.id
            ..eventType = (map['event_type'] as String?) ?? local.eventType
            ..subType = map['sub_type'] as String?
            ..startTime = _dateTimeOrEpoch(map['start_time'])
            ..endTime = _dateTimeOrNull(map['end_time'])
            ..note = map['note'] as String?
            ..isSynced = true
            ..updatedAt = remoteUpdatedAt;
          merged++;
        }
      }
    });

    return merged;
  }

  DateTime _dateTimeOrEpoch(dynamic value) {
    if (value is String) return DateTime.parse(value).toUtc();
    if (value is DateTime) return value.toUtc();
    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }

  DateTime? _dateTimeOrNull(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.parse(value).toUtc();
    if (value is DateTime) return value.toUtc();
    return null;
  }

  Future<String> _getFamilyId(String userId) async {
    final rows = await _supabase
        .from('profiles')
        .select('family_id')
        .eq('id', userId)
        .limit(1);

    if (rows.isEmpty) {
      throw const SyncException(
        'Kritik Hata: Family ID bulunamadi, senkronizasyon durduruldu',
      );
    }

    final familyId = rows.first['family_id'] as String?;
    if (familyId == null || familyId.isEmpty) {
      throw const SyncException(
        'Kritik Hata: Family ID bulunamadi, senkronizasyon durduruldu',
      );
    }

    return familyId;
  }
}
