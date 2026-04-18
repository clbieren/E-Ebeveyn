import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class DailySummaryCard extends StatelessWidget {
  const DailySummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accent,
    super.key,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 4,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
