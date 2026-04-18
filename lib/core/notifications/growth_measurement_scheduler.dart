import '../../features/child/data/models/child_model.dart';
import 'notification_service.dart';

/// 3 aydan küçük bebekler için haftalık, sonrasında aylık boy/kilo hatırlatması (zorunlu değil).
final class GrowthMeasurementScheduler {
  GrowthMeasurementScheduler._();
  static final GrowthMeasurementScheduler instance =
      GrowthMeasurementScheduler._();

  static const int _idBase = 801000;

  int _notificationId(String childSyncId) {
    var h = childSyncId.hashCode;
    if (h < 0) h = -h;
    return _idBase + (h % 400000);
  }

  Future<void> rescheduleForChild(ChildModel child) async {
    final granted = await NotificationService.instance.requestPermissions();
    if (!granted) return;

    final nid = _notificationId(child.syncId);
    await NotificationService.instance.cancelReminder(nid);

    final ageDays = DateTime.now().difference(child.birthDate.toLocal()).inDays;
    final intervalDays = ageDays < 90 ? 7 : 30;
    final when = DateTime.now().add(Duration(days: intervalDays));

    await NotificationService.instance.scheduleReminder(
      nid,
      'Boy / kilo hatırlatması',
      '${child.name}: son boy ve kiloyu güncellemek ister misiniz? '
          'Zorunlu değil; sadece nazik bir hatırlatma.',
      when,
    );
  }

  Future<void> rescheduleAll(List<ChildModel> children) async {
    for (final c in children) {
      await rescheduleForChild(c);
    }
  }
}
