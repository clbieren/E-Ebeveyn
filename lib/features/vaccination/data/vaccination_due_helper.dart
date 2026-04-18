import 'vaccination_schedule.dart';

enum VaccineDueUiStatus {
  completed,
  overdue,
  dueSoon,
  upcoming,
}

/// [birthDate] doğum (yerel veya UTC; ay hesabı için yerel kullanılır).
final class VaccinationDueHelper {
  VaccinationDueHelper._();

  /// Doğum + [monthAge] ay → takvim günü (ay sonu taşması DateTime ile çözülür).
  static DateTime dueCalendarDate(DateTime birthDate, int monthAge) {
    final local = birthDate.toLocal();
    return DateTime(local.year, local.month + monthAge, local.day);
  }

  static VaccineDueUiStatus statusFor(
    DateTime todayLocal,
    DateTime dueLocal,
    bool completed,
  ) {
    if (completed) return VaccineDueUiStatus.completed;
    final t = DateTime(todayLocal.year, todayLocal.month, todayLocal.day);
    final d = DateTime(dueLocal.year, dueLocal.month, dueLocal.day);
    if (t.isAfter(d)) return VaccineDueUiStatus.overdue;
    if (!t.isBefore(d.subtract(const Duration(days: 14)))) {
      return VaccineDueUiStatus.dueSoon;
    }
    return VaccineDueUiStatus.upcoming;
  }

  static String statusLabelTr(VaccineDueUiStatus s) {
    return switch (s) {
      VaccineDueUiStatus.completed => 'Tamamlandı',
      VaccineDueUiStatus.overdue => 'Gecikmiş',
      VaccineDueUiStatus.dueSoon => 'Vadesi geldi / yakın',
      VaccineDueUiStatus.upcoming => 'Yakında',
    };
  }

  static List<VaccineScheduleEntry> sortedByDueDate(DateTime birthLocal) {
    final withDue = kTurkeyInfantVaccineSchedule
        .map(
          (e) => MapEntry(
            dueCalendarDate(birthLocal, e.monthAge),
            e,
          ),
        )
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return withDue.map((e) => e.value).toList();
  }
}
