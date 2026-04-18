import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Regex ve Formatters için eklendi
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/bootstrap/growth_reminder_bootstrap.dart';
import '../../../core/navigation/page_routes.dart';
import '../../../core/notifications/growth_measurement_scheduler.dart';
import '../../child/providers/child_providers.dart';
import '../../main/presentation/main_layout.dart';

/// İlk açılış ekranı — kullanıcının bebeğini kaydettiği yer.
///
/// Yönlendirme: Realm'da çocuk yoksa → buraya gelir.
/// Kaydet → Realm'a yaz → HomeScreen'e geç (push yerine replacement).
class OnboardingScreen extends HookConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final selectedDate = useState<DateTime?>(null);
    final selectedGender = useState<String>('girl');
    final heightController = useTextEditingController();
    final weightController = useTextEditingController();
    final isLoading = useState(false);
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final dateController = useTextEditingController();

    useEffect(() {
      dateController.text =
          selectedDate.value != null ? _formatDate(selectedDate.value!) : '';
      return null;
    }, [selectedDate.value]);

    Future<void> pickDate() async {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(now.year - 3),
        lastDate: now,
        helpText: 'Doğum Tarihini Seç',
        cancelText: 'İptal',
        confirmText: 'Tamam',
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
          ),
          child: child!,
        ),
      );
      if (picked != null) selectedDate.value = picked;
    }

    Future<void> onSave() async {
      if (!formKey.currentState!.validate()) return;
      if (selectedDate.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen doğum tarihini seçin.')),
        );
        return;
      }

      isLoading.value = true;
      FocusScope.of(context).unfocus();

      try {
        final parsedHeight =
            double.parse(heightController.text.trim().replaceAll(',', '.'));
        final parsedWeight =
            double.parse(weightController.text.trim().replaceAll(',', '.'));
        final childId = ref.read(childRepositoryProvider).create(
              name: nameController.text.trim(),
              gender: selectedGender.value,
              height: parsedHeight,
              weight: parsedWeight,
              birthDate: selectedDate.value!,
            );

        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) {
          throw Exception('Oturum bulunamadi');
        }

        final profileRows = await Supabase.instance.client
            .from('profiles')
            .select('family_id')
            .eq('id', user.id)
            .limit(1);
        if (profileRows.isEmpty ||
            profileRows.first['family_id'] == null ||
            (profileRows.first['family_id'] as String).isEmpty) {
          throw Exception('Family ID bulunamadi');
        }
        final familyId = profileRows.first['family_id'] as String;
        final child = ref.read(childRepositoryProvider).findById(childId);
        if (child == null) {
          throw Exception('Çocuk kaydı oluşturulamadı');
        }

        await Supabase.instance.client.from('children').upsert({
          'id': child.syncId,
          'user_id': user.id,
          'family_id': familyId,
          'name': child.name,
          'gender': child.gender,
          'height': child.height,
          'weight': child.weight,
          'birth_date': child.birthDate.toIso8601String(),
          'updated_at': child.updatedAt.toIso8601String(),
          'created_at': child.createdAt.toIso8601String(),
        });

        await GrowthMeasurementScheduler.instance.rescheduleForChild(child);

        if (!context.mounted) return;
        Navigator.of(context).pushReplacement(
          AppPageRoutes.fade<void>(
            const GrowthReminderBootstrap(body: MainLayout()),
          ),
        );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kayit tamamlanamadi: $e')),
          );
        }
      } finally {
        if (!context.mounted) return;
        isLoading.value = false;
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 64),

                // ── İkon ──────────────────────────────────────────────────
                const Center(
                  child: _WelcomeIcon(),
                ),

                const SizedBox(height: 40),

                // ── Başlık ────────────────────────────────────────────────
                Text(
                  'Bebeğini Tanıtalım',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Takibe başlamak için detaylı çocuk bilgisini girin.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                // ── Ad Alanı ──────────────────────────────────────────────
                TextFormField(
                  controller: nameController,
                  enabled: !isLoading.value,
                  // DÜZELTME: İngilizce otomatik büyük harf kuralı Türkçe'yi bozduğu için iptal edildi.
                  // textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  // DÜZELTME: Türkçe karakterleri %100 tanıyan filtre eklendi.

                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Bebeğin Adı',
                    hintText: 'Örn: Zeynep',
                    prefixIcon: Icon(
                      Icons.child_care_rounded,
                      size: 20,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Lütfen bebeğinin adını gir.';
                    }
                    if (v.trim().length < 2) {
                      return 'Ad en az 2 karakter olmalı.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment<String>(value: 'girl', label: Text('Kız')),
                    ButtonSegment<String>(value: 'boy', label: Text('Erkek')),
                  ],
                  selected: {selectedGender.value},
                  onSelectionChanged: isLoading.value
                      ? null
                      : (values) => selectedGender.value = values.first,
                ),

                const SizedBox(height: 16),

                // ── Doğum Tarihi ──────────────────────────────────────────
                GestureDetector(
                  onTap: isLoading.value ? null : pickDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      readOnly: true,
                      enabled: !isLoading.value,
                      style: TextStyle(
                        color: selectedDate.value != null
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 16,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Doğum Tarihi',
                        hintText: 'Seçmek için dokun',
                        prefixIcon: Icon(
                          Icons.cake_outlined,
                          size: 20,
                        ),
                        suffixIcon: Icon(
                          Icons.calendar_today_rounded,
                          size: 18,
                        ),
                      ),
                      controller: dateController,
                      validator: (_) => selectedDate.value == null
                          ? 'Lütfen doğum tarihini seçin.'
                          : null,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: heightController,
                        enabled: !isLoading.value,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Boy (cm)',
                          hintText: 'Orn: 64',
                        ),
                        validator: (v) {
                          final value = double.tryParse(
                            (v ?? '').trim().replaceAll(',', '.'),
                          );
                          if (value == null || value <= 0) return 'Gecerli boy';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: weightController,
                        enabled: !isLoading.value,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Kilo (kg)',
                          hintText: 'Orn: 6.5',
                        ),
                        validator: (v) {
                          final value = double.tryParse(
                            (v ?? '').trim().replaceAll(',', '.'),
                          );
                          if (value == null || value <= 0)
                            return 'Gecerli kilo';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                // ── Kaydet Butonu ─────────────────────────────────────────
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading.value ? null : onSave,
                    child: isLoading.value
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation(
                                  Theme.of(context).colorScheme.onSurface),
                            ),
                          )
                        : const Text(
                            'Takibe Başla',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }
}

class _WelcomeIcon extends StatelessWidget {
  const _WelcomeIcon();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [cs.primaryContainer, cs.surface],
          radius: 1.2,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.primary.withAlpha(102), width: 1),
      ),
      child: Icon(
        Icons.child_friendly_rounded,
        size: 40,
        color: cs.primary,
      ),
    );
  }
}
