import 'package:supabase_flutter/supabase_flutter.dart';

import '../../child/data/models/child_model.dart';
import 'vaccination_due_helper.dart';

/// Supabase `child_vaccine_logs` tablosu (önerilen şema):
/// ```sql
/// create table if not exists public.child_vaccine_logs (
///   id uuid primary key default gen_random_uuid(),
///   child_id uuid not null references public.children(id) on delete cascade,
///   family_id uuid not null,
///   user_id uuid not null,
///   vaccine_id text not null,
///   is_completed boolean not null default true,
///   completed_at timestamptz not null default now(),
///   created_at timestamptz not null default now(),
///   updated_at timestamptz not null default now(),
///   unique (child_id, vaccine_id)
/// );
/// ```
final class VaccinationRepository {
  VaccinationRepository(this._client);

  final SupabaseClient _client;

  Future<Set<String>> fetchCompletedKeys(String childSyncId) async {
    final rows = await _client
        .from('child_vaccine_logs')
        .select('vaccine_id')
        .eq('child_id', childSyncId)
        .eq('is_completed', true);

    final set = <String>{};
    for (final row in rows) {
      final map = Map<String, dynamic>.from(row as Map);
      final k = map['vaccine_id']?.toString();
      if (k != null && k.isNotEmpty) set.add(k);
    }
    return set;
  }

  Future<void> markCompleted({
    required ChildModel child,
    required String vaccineKey,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Oturum bulunamadı');
    }

    final profileRows = await _client
        .from('profiles')
        .select('family_id')
        .eq('id', user.id)
        .limit(1);

    if (profileRows.isEmpty) {
      throw StateError('Profil bulunamadı');
    }
    final familyId = profileRows.first['family_id'] as String?;
    if (familyId == null || familyId.isEmpty) {
      throw StateError('family_id bulunamadı');
    }

    final now = DateTime.now().toUtc();
    final iso = now.toIso8601String();

    await _client.from('child_vaccine_logs').upsert(
      {
        'child_id': child.syncId,
        'family_id': familyId,
        'user_id': user.id,
        'vaccine_id': vaccineKey,
        'is_completed': true,
        'completed_at': iso,
        'updated_at': iso,
        'created_at': iso,
      },
      onConflict: 'child_id,vaccine_id',
    );
  }

  /// AI koç için kısa Türkçe bağlam (hata durumunda boş).
  Future<String> buildAiContext(ChildModel child) async {
    Set<String> done = {};
    try {
      done = await fetchCompletedKeys(child.syncId);
    } catch (_) {
      return '';
    }

    final birth = child.birthDate.toLocal();
    final today = DateTime.now();
    final parts = <String>[];

    for (final e
        in VaccinationDueHelper.sortedByDueDate(child.birthDate.toLocal())) {
      if (done.contains(e.key)) continue;
      final due = VaccinationDueHelper.dueCalendarDate(birth, e.monthAge);
      final st = VaccinationDueHelper.statusFor(
        today,
        due,
        false,
      );
      parts.add(
        '${e.label} → ${due.toIso8601String().split('T').first} '
        '(${VaccinationDueHelper.statusLabelTr(st)})',
      );
      if (parts.length >= 10) break;
    }

    if (parts.isEmpty) {
      return 'Aşı takvimi: kayıtlı çekirdek liste için eksik doz görünmüyor '
          '(veya uzaktan okunamadı).';
    }
    return 'Yaklaşan veya tamamlanmamış aşılar: ${parts.join('; ')}.';
  }
}
