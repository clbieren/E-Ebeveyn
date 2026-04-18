import 'package:realm/realm.dart' hide Uuid;
import 'package:uuid/uuid.dart';

import '../../features/child/data/models/child_model.dart';
import '../../features/event_log/data/models/event_log_model.dart';
import '../../features/user/data/models/user_model.dart';
import '../constants/app_constants.dart';

abstract final class RealmConfig {
  RealmConfig._();

  static final List<SchemaObject> schemas = [
    UserModel.schema,
    ChildModel.schema,
    EventLogModel.schema,
  ];

  static Configuration local({String? path}) {
    return Configuration.local(
      schemas,
      schemaVersion: AppConstants.realmSchemaVersion,
      path: path,
      migrationCallback: _migrate,
    );
  }

  static void _migrate(Migration migration, int oldSchemaVersion) {
    // ── v1 → v2: EventLogModel'e syncId eklendi ──────────────────────────────
    if (oldSchemaVersion < 2) {
      const uuid = Uuid();
      for (final event in migration.newRealm.all<EventLogModel>()) {
        if (event.syncId.isEmpty) {
          event.syncId = uuid.v4();
        }
      }
    }

    // ── v2 → v3: EventLogModel'e subType eklendi (nullable) ──────────────────
    // Nullable alan Realm'da otomatik null başlar — veri migration gerekmez.
    // if (oldSchemaVersion < 3) { /* no-op */ }

    // ── v3 → v4: ChildModel'e gender/height/weight eklendi ───────────────────
    if (oldSchemaVersion < 4) {
      for (final child in migration.newRealm.all<ChildModel>()) {
        if (child.gender.isEmpty) child.gender = 'unknown';
        if (child.height <= 0) child.height = 0;
        if (child.weight <= 0) child.weight = 0;
      }
    }
  }
}
