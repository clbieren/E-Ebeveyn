/// Türkiye bebek aşı takvimi (özet) — ay cinsinden plan.
///
/// [monthAge] doğumdan itibaren tam ay (0 = doğum).
final class VaccineScheduleEntry {
  const VaccineScheduleEntry({
    required this.key,
    required this.monthAge,
    required this.label,
  });

  final String key;
  final int monthAge;
  final String label;
}

/// Sabit takvim — UI ve AI bağlamı tek kaynak.
const List<VaccineScheduleEntry> kTurkeyInfantVaccineSchedule = [
  VaccineScheduleEntry(
    key: 'hep_b_1',
    monthAge: 0,
    label: 'Hepatit B (1)',
  ),
  VaccineScheduleEntry(
    key: 'hep_b_2',
    monthAge: 1,
    label: 'Hepatit B (2)',
  ),
  VaccineScheduleEntry(
    key: 'bcg',
    monthAge: 2,
    label: 'BCG',
  ),
  VaccineScheduleEntry(
    key: 'karma5_1',
    monthAge: 2,
    label: "5'li Karma (1)",
  ),
  VaccineScheduleEntry(
    key: 'kpa_1',
    monthAge: 2,
    label: 'KPA (1)',
  ),
  VaccineScheduleEntry(
    key: 'karma5_2',
    monthAge: 4,
    label: "5'li Karma (2)",
  ),
  VaccineScheduleEntry(
    key: 'kpa_2',
    monthAge: 4,
    label: 'KPA (2)',
  ),
  VaccineScheduleEntry(
    key: 'hep_b_3',
    monthAge: 6,
    label: 'Hepatit B (3)',
  ),
  VaccineScheduleEntry(
    key: 'karma5_3',
    monthAge: 6,
    label: "5'li Karma (3)",
  ),
  VaccineScheduleEntry(
    key: 'opa_1',
    monthAge: 6,
    label: 'OPA (1)',
  ),
  VaccineScheduleEntry(
    key: 'kkk_1',
    monthAge: 12,
    label: 'KKK (1)',
  ),
  VaccineScheduleEntry(
    key: 'varicella',
    monthAge: 12,
    label: 'Suçiçeği',
  ),
  VaccineScheduleEntry(
    key: 'kpa_booster',
    monthAge: 12,
    label: 'KPA (Pekiştirme)',
  ),
  VaccineScheduleEntry(
    key: 'karma5_booster',
    monthAge: 18,
    label: "5'li Karma (Pekiştirme)",
  ),
  VaccineScheduleEntry(
    key: 'opa_2',
    monthAge: 18,
    label: 'OPA (2)',
  ),
  VaccineScheduleEntry(
    key: 'hep_a_1',
    monthAge: 18,
    label: 'Hepatit A (1)',
  ),
  VaccineScheduleEntry(
    key: 'hep_a_2',
    monthAge: 24,
    label: 'Hepatit A (2)',
  ),
  VaccineScheduleEntry(
    key: 'kkk_2',
    monthAge: 48,
    label: 'KKK (2)',
  ),
  VaccineScheduleEntry(
    key: 'karma4_booster',
    monthAge: 48,
    label: "4'lü Karma (Pekiştirme)",
  ),
];
