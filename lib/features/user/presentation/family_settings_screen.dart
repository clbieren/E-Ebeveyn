import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/family/providers/family_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shimmer_skeleton.dart';

class FamilySettingsScreen extends ConsumerStatefulWidget {
  const FamilySettingsScreen({super.key});

  @override
  ConsumerState<FamilySettingsScreen> createState() =>
      _FamilySettingsScreenState();
}

class _FamilySettingsScreenState extends ConsumerState<FamilySettingsScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _joining = false;
  bool _creating = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inviteCodeAsync = ref.watch(familyInviteCodeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aile Ayarlari'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Davet Kodu',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: inviteCodeAsync.when(
                loading: () => const Center(
                  child: ShimmerSkeleton(
                      height: 28,
                      width: 160,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                ),
                error: (_, __) => Text(
                  '-- ----',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 28,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                data: (code) => Row(
                  children: [
                    Expanded(
                      child: Text(
                        (code ?? '-- ----').toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 28,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: code == null
                          ? null
                          : () async {
                              await Clipboard.setData(
                                ClipboardData(text: code.toUpperCase()),
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Davet kodu kopyalandi'),
                                ),
                              );
                            },
                      icon: const Icon(Icons.copy_rounded),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _creating ? null : _createFamily,
              child: _creating
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Yeni Aile Olustur / Kod Uret'),
            ),
            const SizedBox(height: 26),
            const Text(
              'Bir Aile Koduna Katil',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              style: const TextStyle(
                letterSpacing: 3,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'ORN: A1B2C3',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: _joining ? null : _joinFamily,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                ),
                child: _joining
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Aileye Katil'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createFamily() async {
    setState(() => _creating = true);
    final result = await ref.read(familyActionsProvider).createFamily();
    if (!mounted) return;
    setState(() => _creating = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.isSuccess
              ? 'Aile olusturuldu. Kod: ${(result.code ?? '-- ----').toUpperCase()}'
              : (result.errorMessage ?? 'Aile olusturma basarisiz'),
        ),
      ),
    );
  }

  Future<void> _joinFamily() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kod 6 haneli olmali')),
      );
      return;
    }

    setState(() => _joining = true);
    final result = await ref.read(familyActionsProvider).joinFamily(code);
    if (!mounted) return;
    setState(() => _joining = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.isSuccess
              ? 'Aileye katildiniz. Veriler senkronize ediliyor.'
              : (result.errorMessage ?? 'Katilma basarisiz'),
        ),
      ),
    );
  }
}
