import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    this.icon = Icons.auto_awesome_rounded,
    this.title = 'Henüz bir aktivite girilmemiş.',
    this.subtitle = 'Bebeginin ilk adimini kaydetmeye ne dersin?',
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textDisabled, size: 34),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textDisabled,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
