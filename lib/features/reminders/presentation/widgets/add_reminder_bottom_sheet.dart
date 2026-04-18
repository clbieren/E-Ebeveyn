import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../providers/reminder_provider.dart';

class AddReminderBottomSheet extends ConsumerStatefulWidget {
  const AddReminderBottomSheet({super.key});

  @override
  ConsumerState<AddReminderBottomSheet> createState() =>
      _AddReminderBottomSheetState();
}

class _AddReminderBottomSheetState
    extends ConsumerState<AddReminderBottomSheet> {
  String _selectedType = 'Beslenme';
  bool _isSubmitting = false;

  static const _types = ['Beslenme', 'Uyku', 'Ilac', 'Diger'];
  static const _durations = <String, Duration>{
    '30 dk': Duration(minutes: 30),
    '1 saat': Duration(hours: 1),
    '2 saat': Duration(hours: 2),
    '3 saat': Duration(hours: 3),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hatirlatici Ekle',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _types
                .map(
                  (type) => ChoiceChip(
                    label: Text(type),
                    selected: _selectedType == type,
                    onSelected: (_) => setState(() => _selectedType = type),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: _selectedType == type
                          ? AppColors.onPrimary
                          : AppColors.textPrimary,
                    ),
                    backgroundColor: AppColors.surface,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ne kadar sure sonra?',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _durations.entries
                .map(
                  (entry) => ElevatedButton(
                    onPressed:
                        _isSubmitting ? null : () => _addReminder(entry.value),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tertiary,
                      foregroundColor: AppColors.onTertiary,
                    ),
                    child: Text(entry.key),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _addReminder(Duration after) async {
    setState(() => _isSubmitting = true);
    await ref.read(reminderProvider.notifier).addReminder(
          type: _selectedType,
          after: after,
        );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.of(context).pop();
  }
}
