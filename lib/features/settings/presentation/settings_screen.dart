import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/navigation/page_routes.dart';
import '../../child/data/models/child_model.dart';
import '../../child/providers/child_providers.dart';
import '../../vaccination/presentation/vaccination_screen.dart';
import '../../user/presentation/family_settings_screen.dart';
import '../../../../core/auth/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.vaccines_rounded),
            title: const Text('Aşı Takvimi'),
            subtitle: const Text('Plan ve tamamlanan dozlar'),
            onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const VaccinationScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.groups_2_rounded),
            title: const Text('Aile Ayarları'),
            subtitle: const Text('Davet kodu oluştur veya aileye katıl'),
            onTap: () => Navigator.of(context).push(
              AppPageRoutes.cupertino<void>(const FamilySettingsScreen()),
            ),
          ),
          TextButton.icon(
            onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Çıkış Yap'),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: OutlinedButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => _AddChildDialog(ref: ref),
                ),
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('Yeni Çocuk Ekle'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: OutlinedButton.icon(
                onPressed: () {
                  final child = ref.read(selectedChildProvider);
                  if (child == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Önce bir çocuk seçin.')),
                    );
                    return;
                  }
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => _UpdateMeasurementsSheet(
                      child: child,
                      ref: ref,
                    ),
                  );
                },
                icon: const Icon(Icons.monitor_weight_outlined),
                label: const Text('Çocuk Ölçümlerini Güncelle'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                onPressed: () async {
                  final child = ref.read(selectedChildProvider);
                  if (child == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Önce silinecek çocuğu seçin.')),
                    );
                    return;
                  }

                  final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Çocuğu Sil'),
                          content: Text(
                              '${child.name} isimli çocuğu silmek istediğinize emin misiniz? Bu işlem geri alınamaz ve çocuğa ait tüm veriler (aşılar, günlük kayıtları vb.) kalıcı olarak silinecektir.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('İptal'),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Evet, Sil'),
                            ),
                          ],
                        ),
                      ) ??
                      false;

                  if (!confirmed) return;
                  if (!context.mounted) return;

                  try {
                    showDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    // Sync remote drop directly targeting supabase cascade rules
                    await Supabase.instance.client
                        .from('children')
                        .delete()
                        .match({'id': child.syncId});

                    // Flush local db references mapping cascading models manually inside child repository
                    ref.read(childRepositoryProvider).delete(child.id);

                    if (context.mounted) {
                      Navigator.of(context).pop(); // Close loading dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Çocuk başarıyla silindi.')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.of(context).pop(); // Close loading dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'İnternet bağlantınızı kontrol edin. Ağ olmadan çocuk silinemez. ($e)'),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.delete_forever_rounded),
                label: const Text('Seçili Çocuğu Sil'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add Child Dialog ──────────────────────────────────────────────────────────

class _AddChildDialog extends StatefulWidget {
  const _AddChildDialog({required this.ref});

  final WidgetRef ref;

  @override
  State<_AddChildDialog> createState() => _AddChildDialogState();
}

class _AddChildDialogState extends State<_AddChildDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  DateTime? _birthDate;
  String _selectedGender = 'girl';

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doğum tarihi zorunlu')),
      );
      return;
    }

    final height = double.parse(
      _heightController.text.trim().replaceAll(',', '.'),
    );
    final weight = double.parse(
      _weightController.text.trim().replaceAll(',', '.'),
    );

    widget.ref.read(childRepositoryProvider).create(
          name: _nameController.text.trim(),
          gender: _selectedGender,
          height: height,
          weight: weight,
          birthDate: _birthDate!,
        );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yeni çocuk eklendi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Çocuk Ekle'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Çocuk adı'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Çocuk adı zorunlu';
                  }
                  if (v.trim().length < 2) {
                    return 'En az 2 karakter girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment<String>(value: 'girl', label: Text('Kız')),
                  ButtonSegment<String>(value: 'boy', label: Text('Erkek')),
                ],
                selected: {_selectedGender},
                onSelectionChanged: (values) {
                  setState(() => _selectedGender = values.first);
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _birthDate == null
                      ? 'Doğum tarihi seç'
                      : '${_birthDate!.day}.${_birthDate!.month}.${_birthDate!.year}',
                ),
                trailing: const Icon(Icons.calendar_today_rounded),
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: DateTime(now.year - 5),
                    lastDate: now,
                  );
                  if (picked != null) {
                    setState(() => _birthDate = picked);
                  }
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(labelText: 'Boy (cm)'),
                      validator: (v) {
                        final normalized =
                            (v ?? '').trim().replaceAll(',', '.');
                        final value = double.tryParse(normalized);
                        if (value == null || value <= 0) {
                          return 'Geçerli boy';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(labelText: 'Kilo (kg)'),
                      validator: (v) {
                        final normalized =
                            (v ?? '').trim().replaceAll(',', '.');
                        final value = double.tryParse(normalized);
                        if (value == null || value <= 0) {
                          return 'Geçerli kilo';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Ekle'),
        ),
      ],
    );
  }
}

// ── Update Measurements Sheet ─────────────────────────────────────────────────

class _UpdateMeasurementsSheet extends StatefulWidget {
  const _UpdateMeasurementsSheet({
    required this.child,
    required this.ref,
  });

  final ChildModel child;
  final WidgetRef ref;

  @override
  State<_UpdateMeasurementsSheet> createState() =>
      _UpdateMeasurementsSheetState();
}

class _UpdateMeasurementsSheetState extends State<_UpdateMeasurementsSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController(
      text: widget.child.height.toStringAsFixed(1),
    );
    _weightController = TextEditingController(
      text: widget.child.weight.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final height = double.parse(
      _heightController.text.trim().replaceAll(',', '.'),
    );
    final weight = double.parse(
      _weightController.text.trim().replaceAll(',', '.'),
    );

    widget.ref.read(childRepositoryProvider).updateMeasurements(
          widget.child.id,
          height: height,
          weight: weight,
        );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ölçümler güncellendi.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${widget.child.name} — Ölçüm Güncelle',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Boy (cm)',
                      prefixIcon: Icon(Icons.height_rounded),
                    ),
                    validator: (v) {
                      final normalized = (v ?? '').trim().replaceAll(',', '.');
                      final value = double.tryParse(normalized);
                      if (value == null || value <= 0) {
                        return 'Geçerli bir boy girin';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Kilo (kg)',
                      prefixIcon: Icon(Icons.monitor_weight_outlined),
                    ),
                    validator: (v) {
                      final normalized = (v ?? '').trim().replaceAll(',', '.');
                      final value = double.tryParse(normalized);
                      if (value == null || value <= 0) {
                        return 'Geçerli bir kilo girin';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
