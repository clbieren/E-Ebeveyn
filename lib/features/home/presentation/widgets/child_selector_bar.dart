import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../child/data/models/child_model.dart';
import '../../../child/providers/child_providers.dart';

/// Ana ekranın üstündeki yatay kaydırılabilir çocuk seçici.
///
/// Seçili çocuk vurgulanır; diğerleri soluktur.
/// Tapping → [SelectedChildId] güncellenir → tüm ekran reaktif güncellenir.
class ChildSelectorBar extends ConsumerWidget {
  const ChildSelectorBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(childrenProvider);
    final selectedId = ref.watch(selectedChildIdProvider);

    return SizedBox(
      height: 72,
      child: childrenAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
        data: (children) => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: children.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final child = children[index];
            final isSelected = child.id == selectedId;

            return _ChildChip(
              child: child,
              isSelected: isSelected,
              onTap: () =>
                  ref.read(selectedChildIdProvider.notifier).select(child.id),
            );
          },
        ),
      ),
    );
  }
}

class _ChildChip extends StatelessWidget {
  const _ChildChip({
    required this.child,
    required this.isSelected,
    required this.onTap,
  });

  final ChildModel child;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryDim.withValues(alpha: 0.25)
              : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outline,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar — isim baş harfi
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.25)
                    : AppColors.outline,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  child.name.isNotEmpty ? child.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.name,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                Text(
                  _ageLabel(child.birthDate),
                  style: TextStyle(
                    color:
                        isSelected ? AppColors.primary : AppColors.textDisabled,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _ageLabel(DateTime birthDate) {
    final now = DateTime.now();
    final diff = now.difference(birthDate);
    final days = diff.inDays;

    if (days < 30) return '$days gün';
    if (days < 365) return '${(days / 30).floor()} ay';
    final years = (days / 365).floor();
    final months = ((days % 365) / 30).floor();
    return months > 0 ? '$years y $months ay' : '$years yaş';
  }
}
