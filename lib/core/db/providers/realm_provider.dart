import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:realm/realm.dart';

import '../../constants/app_constants.dart';
import '../realm_config.dart';

final realmProvider = Provider<Realm>((ref) {
  // WEB DESTEĞİ KONTROLÜ
  if (kIsWeb) {
    throw UnsupportedError("Realm is not supported on web platform");
  }

  // Mobil cihazda normal çalışmaya devam et
  final config = Configuration.local(
    RealmConfig.schemas,
    schemaVersion: AppConstants.realmSchemaVersion,
  );

  return Realm(config);
});
