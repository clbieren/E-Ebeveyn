import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:realm/realm.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/db/providers/realm_provider.dart';
import '../../../core/notifications/notification_service.dart';
import '../../child/data/models/child_model.dart';
import '../../child/providers/child_providers.dart';
import '../../event_log/data/models/event_log_model.dart';
import '../../vaccination/providers/vaccination_providers.dart';
import '../data/repositories/ai_repository.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  final apiKey =
      (dotenv.env['API_KEY'] ?? dotenv.env['GEMINI_API_KEY'] ?? '').trim();
  debugPrint('--- AI KOÇ API KEY DURUMU ---');
  debugPrint(apiKey.isEmpty
      ? 'HATA: API KEY BOŞ GELDİ!'
      : 'BAŞARILI: API KEY OKUNDU!');

  return AiRepository(apiKey: apiKey);
});

final aiCoachProvider = StateNotifierProvider<AiCoachController, AiCoachState>(
  (ref) => AiCoachController(ref),
);

enum AiChatRole { user, ai }

final class AiChatMessage {
  const AiChatMessage({required this.role, required this.text});
  final AiChatRole role;
  final String text;

  Map<String, dynamic> toJson() => {
        'role': role.name,
        'text': text,
      };

  factory AiChatMessage.fromJson(Map<String, dynamic> json) {
    final roleName = json['role']?.toString() ?? AiChatRole.ai.name;
    final role =
        roleName == AiChatRole.user.name ? AiChatRole.user : AiChatRole.ai;
    return AiChatMessage(role: role, text: json['text']?.toString() ?? '');
  }
}

final class AiConversationHistory {
  const AiConversationHistory({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.messages,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final List<AiChatMessage> messages;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'messages': messages.map((e) => e.toJson()).toList(),
      };

  factory AiConversationHistory.fromJson(Map<String, dynamic> json) {
    final rawMessages = (json['messages'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(AiChatMessage.fromJson)
        .toList();
    return AiConversationHistory(
      id: json['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: json['title']?.toString() ?? 'Sohbet',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      messages: rawMessages,
    );
  }
}

final class AiCoachState {
  const AiCoachState({
    required this.messages,
    required this.isLoading,
    required this.histories,
    this.activeHistoryId,
  });

  final List<AiChatMessage> messages;
  final bool isLoading;
  final List<AiConversationHistory> histories;
  final String? activeHistoryId;

  AiCoachState copyWith({
    List<AiChatMessage>? messages,
    bool? isLoading,
    List<AiConversationHistory>? histories,
    String? activeHistoryId,
  }) {
    return AiCoachState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      histories: histories ?? this.histories,
      activeHistoryId: activeHistoryId ?? this.activeHistoryId,
    );
  }
}

class AiCoachController extends StateNotifier<AiCoachState> {
  AiCoachController(this._ref)
      : super(const AiCoachState(
          messages: <AiChatMessage>[],
          isLoading: false,
          histories: <AiConversationHistory>[],
        )) {
    _loadHistoriesForSelectedChild();
    _ref.listen<ObjectId?>(selectedChildIdProvider, (_, __) {
      _loadHistoriesForSelectedChild();
    });
  }

  final Ref _ref;

  Future<void> analyzeLast3Days() async {
    final childId = _ref.read(selectedChildIdProvider);
    if (childId == null) {
      state = state.copyWith(
        messages: [
          ...state.messages,
          const AiChatMessage(
            role: AiChatRole.ai,
            text: 'Analiz için önce çocuk seçmelisiniz.',
          ),
        ],
      );
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final realm = _ref.read(realmProvider);
      final events = _getLast3DaysEvents(realm, childId);
      if (events.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          messages: [
            ...state.messages,
            const AiChatMessage(
              role: AiChatRole.ai,
              text:
                  'Henüz analiz edebileceğim yeterli kayıt görünmüyor. Birkaç uyku/beslenme/bez verisi girdikten sonra tekrar birlikte bakalım.',
            ),
          ],
        );
        return;
      }
      final selectedChild = _ref.read(selectedChildProvider);
      final prompt = _buildPrompt(events, selectedChild);
      final vaccineCtx = selectedChild == null
          ? ''
          : await _ref
              .read(vaccinationRepositoryProvider)
              .buildAiContext(selectedChild);
      final result = await _ref.read(aiRepositoryProvider).generate(
            prompt,
            extraContext: vaccineCtx.isEmpty ? null : vaccineCtx,
          );
      await HapticFeedback.lightImpact();
      final updatedMessages = [
        ...state.messages,
        AiChatMessage(
            role: AiChatRole.ai,
            text: result.isEmpty ? 'AI cevap veremedi.' : result),
      ];
      state = state.copyWith(
        isLoading: false,
        messages: updatedMessages,
      );
      await _persistActiveConversation(updatedMessages);
    } catch (e, st) {
      debugPrint('🛑 AI PATLADI: $e');
      debugPrintStack(stackTrace: st);
      state = state.copyWith(
        isLoading: false,
        messages: [
          ...state.messages,
          const AiChatMessage(
            role: AiChatRole.ai,
            text:
                'AI analiz şu anda yapılamıyor. Lütfen daha sonra tekrar deneyin.',
          ),
        ],
      );
    }
  }

  Future<void> sendMessage(String mesaj) async {
    final trimmed = mesaj.trim();
    if (trimmed.isEmpty) return;

    debugPrint('1. AI İSTEĞİ BAŞLADI: $trimmed');

    state = state.copyWith(
      isLoading: true,
      messages: [
        ...state.messages,
        AiChatMessage(role: AiChatRole.user, text: trimmed),
      ],
    );

    try {
      final selectedChild = _ref.read(selectedChildProvider);
      final vaccineCtx = selectedChild == null
          ? ''
          : await _ref
              .read(vaccinationRepositoryProvider)
              .buildAiContext(selectedChild);
      final text = await _ref.read(aiRepositoryProvider).generate(
            _buildChatPrompt(trimmed, selectedChild),
            extraContext: vaccineCtx.isEmpty ? null : vaccineCtx,
          );
      debugPrint('2. AI CEVAP VERDİ: $text');
      final updatedMessages = [
        ...state.messages,
        AiChatMessage(
          role: AiChatRole.ai,
          text: text.isEmpty ? 'AI cevap veremedi.' : text,
        ),
      ];
      state = state.copyWith(
        isLoading: false,
        messages: updatedMessages,
      );
      await _persistActiveConversation(updatedMessages);
    } catch (e, st) {
      debugPrint('🛑 AI PATLADI: $e');
      debugPrintStack(stackTrace: st);
      state = state.copyWith(isLoading: false);
    }
  }

  void startNewConversation() {
    state = state.copyWith(messages: const [], activeHistoryId: '');
  }

  void loadConversation(String historyId) {
    final target = state.histories.where((h) => h.id == historyId).firstOrNull;
    if (target == null) return;
    state = state.copyWith(
      messages: target.messages,
      activeHistoryId: target.id,
    );
  }

  Future<void> runProactiveAnalysisInBackground() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getInt('last_proactive_ai_check') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Sadece 24 saatte bir çalıştır.
    if (now - lastCheck < 86400000) return;

    final childId = _ref.read(selectedChildIdProvider);
    if (childId == null) return;
    final child = _ref.read(selectedChildProvider);
    if (child == null) return;

    final realm = _ref.read(realmProvider);
    final since = DateTime.now().toUtc().subtract(const Duration(hours: 48));
    final events = realm.all<EventLogModel>().query(
      r'childId == $0 AND startTime >= $1',
      [childId, since],
    ).toList();

    if (events.length < 3) return; // Yeterli log yoksa analiz etme.

    try {
      final prompt = _buildProactivePrompt(events, child);
      final result = await _ref.read(aiRepositoryProvider).generate(prompt);

      if (result.isNotEmpty && !result.toLowerCase().contains('analiz_yok')) {
        await prefs.setInt('last_proactive_ai_check', now);

        await NotificationService.instance.scheduleReminder(
          DateTime.now().millisecondsSinceEpoch % 100000,
          '${child.name} İçin Koç Gözlemi',
          result,
          DateTime.now()
              .add(const Duration(seconds: 15)), // Gecikmeli local push
        );
      }
    } catch (_) {}
  }

  List<EventLogModel> _getLast3DaysEvents(Realm realm, ObjectId childId) {
    final since = DateTime.now().toUtc().subtract(const Duration(days: 3));
    return realm.all<EventLogModel>().query(
      r'child_id == $0 AND start_time >= $1 SORT(start_time DESC)',
      [childId, since],
    ).toList();
  }

  String _buildPrompt(List<EventLogModel> events, ChildModel? child) {
    final buffer = StringBuffer();

    buffer.writeln('GÖREVİN: Sen uzman, şefkatli bir bebek koçusun.\n'
        'KESİN KURAL 1: ASLA "şöyle olmalı", "bunu yapmalısın" gibi kesin yargı ve teşhis/emir ifadeleri kullanma! '
        'Hep "ihtimali olabilir", "denemeyi düşünebilirsiniz", "görünüşe göre" şeklinde yumuşak dil kullan.\n'
        'KESİN KURAL 2: MESAJININ EN SONUNDA MUTLAKA anneyi/babayı dinlenmeye teşvik eden ve durumlarını yoklayan destekleyici bir '
        'söz söyle! (Örn: Sizin de dinlenmeye ihtiyacınız var unutmayın, siz iyiyseniz bebeğiniz de o kadar iyidir.)');
    buffer.writeln();
    buffer.writeln('Çocuk Profili:');
    if (child == null) {
      buffer.writeln('- Profil bilgisi bulunamadı.');
    } else {
      buffer.writeln('- Ad: ${child.name}');
      buffer.writeln('- Cinsiyet: ${_toTurkishGender(child.gender)}');
      buffer.writeln('- Boy: ${child.height.toStringAsFixed(1)} cm');
      buffer.writeln('- Kilo: ${child.weight.toStringAsFixed(1)} kg');
      buffer.writeln('- Yaş: ${_ageLabel(child.birthDate)}');
    }
    buffer.writeln();
    buffer.writeln('Son 3 Gün Veri Seti (uyku/beslenme/bez):');

    if (events.isEmpty) {
      buffer.writeln('- Son 3 günde event kaydı bulunamadı.');
      buffer.writeln(
        '- Düzenli veri girişini teşvik eden, nazik bir takip rutini öner.',
      );
      return buffer.toString();
    }

    for (final event in events) {
      final type = event.eventType;
      final sub = event.subType ?? '-';
      final start = event.startTime.toUtc().toIso8601String();
      final end = event.endTime?.toUtc().toIso8601String() ?? 'devam ediyor';

      buffer.writeln(
        '- tür: $type | alt_tür: $sub | başlangıç: $start | bitiş: $end',
      );
    }

    final sleepCount =
        events.where((e) => e.eventType == AppConstants.eventTypeSleep).length;
    final feedCount =
        events.where((e) => e.eventType == AppConstants.eventTypeFeed).length;
    final diaperCount =
        events.where((e) => e.eventType == AppConstants.eventTypeDiaper).length;

    buffer.writeln();
    buffer.writeln('Özet Sayılar:');
    buffer.writeln('- Uyku kaydı: $sleepCount');
    buffer.writeln('- Beslenme kaydı: $feedCount');
    buffer.writeln('- Bez kaydı: $diaperCount');
    buffer.writeln();
    buffer.writeln(
      'Cevap formatı: Markdown kullan. Kısa başlık + maddeler + uygulanabilir öneriler. '
      'Sonda "gerekirse doktoruna danışman iyi olur" gibi güvenli bir not ekle.',
    );

    return buffer.toString();
  }

  String _buildProactivePrompt(List<EventLogModel> events, ChildModel child) {
    final buffer = StringBuffer();
    buffer.writeln(
        'GÖREVİN: Sen proaktif, destekleyici, görünmez bir yapay zeka bebek koçusun.\n'
        'Girdi olarak son 48 saatlik loglara bak. SADECE belirgin bir anormallik/değişim varsa '
        'kısacık (maksimum 2-3 cümlelik) nazik bir uyanıklık ve tespit bildirimi üret.\n'
        'KESİN KURAL 1: ASLA kesin yargılarda bulunma, emir kipi kullanma! "Olabildiğini görüyorum", "belki de..." gibi dil kullan.\n'
        'KESİN KURAL 2: MESAJIN SONUNA MUTLAKA kısa bir "Lütfen siz de dinlenmeyi ihmal etmeyin, kendinize iyi bakın" benzeri '
        'ebeveynin durumunu yoklayan destekleyici bir cümle ekle.\n'
        'KESİN KURAL 3: Eğer loglarda DİKKATE DEĞER BİR DEĞİŞİM YOKSA, SADECE VE SADECE "ANALİZ_YOK" kelimesini döndür.\n\n'
        'Ad: ${child.name}, Yaş: ${_ageLabel(child.birthDate)}\n'
        'Son 48 Saatteki Kayıtlar:');
    for (final e in events) {
      buffer.writeln('- ${e.eventType} (${e.subType ?? '-'})');
    }
    return buffer.toString();
  }

  String _buildChatPrompt(String userMessage, ChildModel? child) {
    final buffer = StringBuffer();
    buffer.writeln(
        'Rol: Şefkatli, yargılamayan, samimi bir bebek bakım koçusun.\n'
        'KESİN KURAL 1: Emir cümleleri ve kesin tıbbi teşhis ifadeleri YASAKTIR. "Olabilir", "deneyebilirsiniz" kullan.\n'
        'KESİN KURAL 2: Mesaj bitiminde MUTLAKA ebeveynin dinlenmesi gerektiğini hatırlatan, şefkatli ve destekleyici kısa bir kapanış cümlesi ekle.');
    if (child != null) {
      buffer.writeln(
          'Bağlam: ${child.name}, Boy=${child.height}cm, Kilo=${child.weight}kg, Yaş=${_ageLabel(child.birthDate)}.');
    }
    buffer.writeln('Kullanıcı: $userMessage');
    return buffer.toString();
  }

  String _toTurkishGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'girl':
        return 'Kız';
      case 'boy':
        return 'Erkek';
      default:
        return gender;
    }
  }

  String _ageLabel(DateTime birthDate) {
    final now = DateTime.now();
    final days = now.difference(birthDate.toLocal()).inDays;
    if (days < 30) return '$days gün';
    if (days < 365) return '${(days / 30).floor()} ay';
    final years = (days / 365).floor();
    final months = ((days % 365) / 30).floor();
    return months > 0 ? '$years yaş $months ay' : '$years yaş';
  }

  String _historyStorageKey() {
    final childId = _ref.read(selectedChildIdProvider);
    if (childId == null) return 'ai_chat_histories_global';
    return 'ai_chat_histories_${childId.toString()}';
  }

  Future<void> _loadHistoriesForSelectedChild() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyStorageKey());
    if (raw == null || raw.isEmpty) {
      state = state.copyWith(histories: const [], activeHistoryId: '');
      return;
    }
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final histories = decoded
          .whereType<Map<String, dynamic>>()
          .map(AiConversationHistory.fromJson)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = state.copyWith(histories: histories, activeHistoryId: '');
    } catch (_) {
      state = state.copyWith(histories: const [], activeHistoryId: '');
    }
  }

  Future<void> _persistActiveConversation(List<AiChatMessage> messages) async {
    if (messages.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final currentId =
        (state.activeHistoryId == null || state.activeHistoryId!.isEmpty)
            ? DateTime.now().microsecondsSinceEpoch.toString()
            : state.activeHistoryId!;
    final title = messages
        .firstWhere(
          (m) => m.role == AiChatRole.user,
          orElse: () => messages.first,
        )
        .text;
    final normalizedTitle =
        title.length > 48 ? '${title.substring(0, 48)}...' : title;
    final newEntry = AiConversationHistory(
      id: currentId,
      title: normalizedTitle,
      createdAt: DateTime.now(),
      messages: messages,
    );

    final updated = [
      newEntry,
      ...state.histories.where((h) => h.id != currentId),
    ];
    final capped = updated.take(30).toList();
    await prefs.setString(
      _historyStorageKey(),
      jsonEncode(capped.map((e) => e.toJson()).toList()),
    );

    state = state.copyWith(
      histories: capped,
      activeHistoryId: currentId,
    );
  }
}
