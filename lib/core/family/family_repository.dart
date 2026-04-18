import 'dart:math';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:realm/realm.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/child/data/models/child_model.dart';
import '../../features/event_log/data/models/event_log_model.dart';
import '../sync/sync_repository.dart';

final class FamilyRepository {
  FamilyRepository(
    this._supabase,
    this._realm,
    this._syncRepository,
  );

  final SupabaseClient _supabase;
  final Realm _realm;
  final SyncRepository _syncRepository;

  Future<String?> getCurrentInviteCode({required String userId}) async {
    try {
      debugPrint(
          '[FamilyRepository] invite_code sorgusu basladi. userId=$userId');
      final profileRows = await _supabase
          .from('profiles')
          .select('family_id')
          .eq('id', userId)
          .limit(1);

      if (profileRows.isEmpty) return null;
      final familyId = profileRows.first['family_id'] as String?;
      if (familyId == null || familyId.isEmpty) return null;

      final familyRows = await _supabase
          .from('families')
          .select('invite_code')
          .eq('id', familyId)
          .limit(1);

      if (familyRows.isEmpty) return null;
      return (familyRows.first['invite_code'] as String?)?.toUpperCase();
    } on PostgrestException catch (e) {
      _debugRlsHints('SELECT', e);
      throw FamilyException(_mapPostgrestError(e));
    } on SocketException {
      throw const FamilyException('Internet baglantisi bulunamadi.');
    } catch (_) {
      throw const FamilyException('Davet kodu alinamadi.');
    }
  }

  Future<String?> createFamily({
    required String userId,
    required bool isOnline,
  }) async {
    if (!isOnline) {
      throw const FamilyException(
          'Internet baglantisi olmadan aile olusturulamaz.');
    }

    try {
      String inviteCode = _generateInviteCode();
      String? familyId;

      for (var i = 0; i < 5; i++) {
        debugPrint(
            '[FamilyRepository] families INSERT denemesi #${i + 1}, invite_code=$inviteCode');
        final inserted = await _supabase
            .from('families')
            .insert(<String, dynamic>{'invite_code': inviteCode})
            .select('id, invite_code')
            .limit(1);

        if (inserted.isNotEmpty) {
          familyId = inserted.first['id'] as String?;
          inviteCode =
              ((inserted.first['invite_code'] as String?) ?? inviteCode)
                  .toUpperCase();
          break;
        }

        inviteCode = _generateInviteCode();
      }

      if (familyId == null) {
        throw const FamilyException(
            'Aile olusturma tamamlanamadi. Lutfen tekrar deneyin.');
      }

      await _supabase.from('profiles').upsert(<String, dynamic>{
        'id': userId,
        'family_id': familyId,
      });

      return inviteCode;
    } on PostgrestException catch (e) {
      _debugRlsHints('INSERT', e);
      throw FamilyException(_mapPostgrestError(e));
    } on SocketException {
      throw const FamilyException('Internet baglantisi bulunamadi.');
    } catch (_) {
      throw const FamilyException(
          'Aile olusturma sirasinda beklenmeyen bir hata olustu.');
    }
  }

  Future<bool> joinFamily({
    required String userId,
    required String code,
    required bool isOnline,
  }) async {
    if (!isOnline) {
      throw const FamilyException(
          'Internet baglantisi olmadan aileye katilamazsiniz.');
    }

    try {
      final normalizedCode = code.trim().toUpperCase();
      if (normalizedCode.length != 6) {
        throw const FamilyException('Kod gecersiz. 6 karakterli kod girin.');
      }

      debugPrint(
          '[FamilyRepository] families SELECT by invite_code=$normalizedCode');
      final rows = await _supabase
          .from('families')
          .select('id')
          .eq('invite_code', normalizedCode)
          .limit(1);

      if (rows.isEmpty) return false;
      final familyId = rows.first['id'] as String?;
      if (familyId == null || familyId.isEmpty) return false;

      await _supabase.from('profiles').upsert(<String, dynamic>{
        'id': userId,
        'family_id': familyId,
      });

      _clearLocalFamilyData();

      await _syncRepository.performFullSync(
        userId: userId,
        isOnline: isOnline,
      );

      return true;
    } on PostgrestException catch (e) {
      _debugRlsHints('SELECT', e);
      throw FamilyException(_mapPostgrestError(e));
    } on SocketException {
      throw const FamilyException('Internet baglantisi bulunamadi.');
    } catch (_) {
      throw const FamilyException('Aileye katilma sirasinda hata olustu.');
    }
  }

  void _clearLocalFamilyData() {
    _realm.write(() {
      _realm.deleteAll<EventLogModel>();
      _realm.deleteAll<ChildModel>();
    });
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(
      6,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  String _mapPostgrestError(PostgrestException e) {
    final code = e.code ?? '';
    final message = e.message.toLowerCase();

    if (message.contains('duplicate') || code == '23505') {
      return 'Kod olusturulurken cakisma oldu, tekrar deneyin.';
    }
    if (message.contains('not found') || message.contains('no rows')) {
      return 'Aile kodu gecersiz.';
    }
    if (code == '42501' || message.contains('row-level security')) {
      return 'Sunucu yetki hatasi (RLS). Lutfen tablo politikalari kontrol edilsin.';
    }
    if (message.contains('network')) {
      return 'Internet baglantisi bulunamadi.';
    }
    return 'Sunucu hatasi olustu. Lutfen daha sonra tekrar deneyin.';
  }

  void _debugRlsHints(String action, PostgrestException e) {
    debugPrint('[FamilyRepository][$action] PostgrestException '
        'code=${e.code} message=${e.message}');
    if (e.code == '42501' ||
        e.message.toLowerCase().contains('row-level security')) {
      debugPrint('[FamilyRepository][$action] RLS ipucu: families tablosunda '
          '$action politikasini ve auth.uid() kosullarini kontrol edin.');
    }
  }
}

final class FamilyException implements Exception {
  const FamilyException(this.userMessage);
  final String userMessage;
}
