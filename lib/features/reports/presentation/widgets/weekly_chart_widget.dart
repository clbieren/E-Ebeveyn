import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/reports_repository.dart';

class WeeklyChartWidget extends StatelessWidget {
  const WeeklyChartWidget({
    required this.title,
    required this.items,
    required this.accent,
    super.key,
  });

  final String title;
  final List<DailyMetric> items;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final maxValue = items.isEmpty
        ? 1.0
        : items
            .map((e) => e.value)
            .reduce((a, b) => a > b ? a : b)
            .clamp(1.0, 9999.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 34,
                    child: Text(
                      item.dayLabel,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          Container(
                            height: 14,
                            color: AppColors.surface,
                          ),
                          FractionallySizedBox(
                            widthFactor:
                                (item.value / maxValue).clamp(0.0, 1.0),
                            child: Container(
                              height: 14,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 44,
                    child: Text(
                      item.value.toStringAsFixed(item.value < 10 ? 1 : 0),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
