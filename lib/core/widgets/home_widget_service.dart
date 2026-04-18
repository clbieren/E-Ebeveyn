import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:realm/realm.dart' hide Uuid;
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';
import '../db/realm_config.dart';
import '../../features/event_log/data/models/event_log_model.dart';
import '../../features/child/data/models/child_model.dart'; // Eğer gerekli olursa

/// Widget tarafındaki tıklamaları arka planda dinler.
/// "Isolate" içinde çalıştığı için Riverpod gibi UI servislerine erişemez.
@pragma('vm:entry-point')
Future<void> backgroundCallback(Uri? uri) async {
  if (uri == null) return;

  final path = uri.host;
  final childId = uri.queryParameters['child_id'];

  if (path == 'log_feed') {
    final type = uri.queryParameters['type'];
    await HomeWidgetService.handleBackgroundFeed(childId, type);
  } else if (path == 'toggle_sleep') {
    await HomeWidgetService.handleBackgroundSleepToggle(childId);
  }
}

class HomeWidgetService {
  static const String appGroupId =
      'group.com.example.babycare'; // iOS için daha sonra ayarlayacağız
  static const String androidWidgetName = 'BabyCareWidgetProvider';

  static Future<void> setup() async {
    // Background callback'i kayıt ediyoruz (main.dart içinden çağrılacak)
    await HomeWidget.setAppGroupId(appGroupId);
    await HomeWidget.registerBackgroundCallback(backgroundCallback);
  }

  /// UI Tarafındaki Değişimlerde Widget'ı Güncelleme Metodu
  static Future<void> updateWidgetState(ObjectId? childIdStr,
      {String? childName}) async {
    if (childIdStr != null) {
      await HomeWidget.saveWidgetData<String>('child_id', childIdStr.hexString);
      if (childName != null) {
        await HomeWidget.saveWidgetData<String>(
            'widget_title_text', "$childName'nin Durumu");
      }
    }

    // Realm üzerinden istatistikleri hesapla ve kaydet
    await _computeAndSaveAIInsight(childIdStr?.hexString);

    // Widget Providerlarına Güncelleme Tetikle
    await HomeWidget.updateWidget(
      name: androidWidgetName,
      iOSName: 'BabyWidget', // İleride iOS tarafı eklenince devreye girecek
    );
  }

  /// Yiyecek Ekleme İşlemi (Mama / Süt)
  static Future<void> handleBackgroundFeed(
      String? providedChildIdHex, String? subType) async {
    final childIdHex = providedChildIdHex ??
        await HomeWidget.getWidgetData<String>('child_id');
    if (childIdHex == null || childIdHex.isEmpty) return;

    final childId = ObjectId.fromHexString(childIdHex);
    final realm = Realm(Configuration.local(RealmConfig.schemas,
        schemaVersion: AppConstants.realmSchemaVersion));
    final now = DateTime.now().toUtc();

    realm.write(() {
      realm.add(
        EventLogModel(
          ObjectId(),
          const Uuid().v4(),
          childId,
          AppConstants.eventTypeFeed,
          now,
          false,
          now,
          now,
          endTime: now,
          subType: subType,
          note: 'Widget üzerinden eklendi',
        ),
      );
    });

    realm.close();
    await _computeAndSaveAIInsight(childIdHex);
    await HomeWidget.updateWidget(
        name: androidWidgetName, iOSName: 'BabyWidget');
  }

  /// Uyku Başlatma / Bitirme İşlemi
  static Future<void> handleBackgroundSleepToggle(
      String? providedChildIdHex) async {
    final childIdHex = providedChildIdHex ??
        await HomeWidget.getWidgetData<String>('child_id');
    if (childIdHex == null || childIdHex.isEmpty) return;

    final childId = ObjectId.fromHexString(childIdHex);
    final realm = Realm(Configuration.local(RealmConfig.schemas,
        schemaVersion: AppConstants.realmSchemaVersion));
    final now = DateTime.now().toUtc();

    // Devam eden uyku var mı kontrol et
    final activeSleep = realm.all<EventLogModel>().query(
        r'child_id == $0 AND event_type == $1 AND end_time == nil',
        [childId, AppConstants.eventTypeSleep]).firstOrNull;

    realm.write(() {
      if (activeSleep != null) {
        // Uyandır
        activeSleep.endTime = now;
        activeSleep.updatedAt = now;
      } else {
        // Uyut (Yeni Başlat)
        realm.add(
          EventLogModel(
            ObjectId(),
            const Uuid().v4(),
            childId,
            AppConstants.eventTypeSleep,
            now,
            false,
            now,
            now,
            subType: null,
            note: 'Widget üzerinden eklendi',
          ),
        );
      }
    });

    realm.close();
    await _computeAndSaveAIInsight(childIdHex);
    await HomeWidget.updateWidget(
        name: androidWidgetName, iOSName: 'BabyWidget');
  }

  /// AI İçgörüsü Hesabı (Yarı bağımsız işlem - Hem UI'dan hem Isolate'den çağrılabilir)
  static Future<void> _computeAndSaveAIInsight(String? childIdHex) async {
    if (childIdHex == null) {
      final saved = await HomeWidget.getWidgetData<String>('child_id');
      if (saved != null) childIdHex = saved;
      if (childIdHex == null) return;
    }

    final config = Configuration.local(
      RealmConfig.schemas,
      schemaVersion: AppConstants.realmSchemaVersion,
    );
    final realm = Realm(config);
    final childId = ObjectId.fromHexString(childIdHex);

    // Son uyku ve beslenmeyi bulalım
    final recentFeed = realm.all<EventLogModel>().query(
      r'child_id == $0 AND event_type == $1 SORT(start_time DESC) LIMIT(1)',
      [childId, AppConstants.eventTypeFeed],
    ).firstOrNull;

    final recentSleep = realm.all<EventLogModel>().query(
      r'child_id == $0 AND event_type == $1 SORT(start_time DESC) LIMIT(1)',
      [childId, AppConstants.eventTypeSleep],
    ).firstOrNull;

    final now = DateTime.now().toUtc();
    String insightText = "Mükemmel gidiyor, güncel kayıt yok.";
    String sleepBtnText = "💤 Uyut"; // Default: Uyut

    // Devam eden uyku var mı kontrolü (Uyandır butonunu belirlemek için)
    final activeSleep = realm.all<EventLogModel>().query(
        r'child_id == $0 AND event_type == $1 AND end_time == nil',
        [childId, AppConstants.eventTypeSleep]).firstOrNull;

    if (activeSleep != null) {
      sleepBtnText = "☀️ Uyandır";
      final hoursAsleep = now.difference(activeSleep.startTime).inHours;
      insightText =
          "Bebek ${hoursAsleep > 0 ? '$hoursAsleep saattir' : 'bir süredir'} uykuda.";
    } else {
      // Bebek uyanık, feed değerine bakalım
      if (recentFeed != null) {
        final hoursSinceFeed = now.difference(recentFeed.startTime).inHours;
        if (hoursSinceFeed >= 3) {
          insightText =
              "Yaklaşık $hoursSinceFeed saattir beslenmedi. Acıkmış olabilir.";
        } else {
          insightText = "Yakın zamanda beslendi, keyfi yerinde görünüyor.";
        }
      }
      if (recentSleep != null && recentSleep.endTime != null) {
        final hoursSinceSleep = now.difference(recentSleep.endTime!).inHours;
        if (hoursSinceSleep >= 4 &&
            (insightText.contains("beslendi") ||
                insightText.contains("Mükemmel"))) {
          insightText = "Uzun süredir uyanık, uykusu gelmiş olabilir.";
        }
      }
    }

    realm.close();

    await HomeWidget.saveWidgetData<String>('sleep_btn_text', sleepBtnText);
    await HomeWidget.saveWidgetData<String>('ai_insight', insightText);
  }
}
