import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../child/providers/child_providers.dart';

/// HomeScreen'in AppBar altında yer alan, seçili çocuğun adını
/// ve yaş/gün bilgisini gösteren minimal başlık şeridi.
class ChildHeader extends ConsumerWidget {
  const ChildHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(selectedChildProvider);
    if (child == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                child.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _ageDetailLabel(child.birthDate),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Senkronizasyon veya bildirim butonu için alan — Görev 4'te dolacak
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  /// "42 günlük" / "3 ay 5 günlük" / "1 yaş 2 aylık" formatlar
  String _ageDetailLabel(DateTime birthDate) {
    final now = DateTime.now();
    final diff = now.difference(birthDate);
    final days = diff.inDays;

    if (days == 0) return 'Yeni doğdu! 🎉';
    if (days < 30) return '$days günlük';
    if (days < 365) {
      final months = (days / 30).floor();
      final remDays = days - months * 30;
      return remDays > 0 ? '$months ay $remDays günlük' : '$months aylık';
    }

    final years = (days / 365).floor();
    final months = ((days % 365) / 30).floor();
    return months > 0 ? '$years yaş $months aylık' : '$years yaşında';
  }
}
