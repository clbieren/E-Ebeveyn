import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/family/providers/family_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../main.dart' show hasFamilyProvider;

class FamilyDecisionScreen extends ConsumerStatefulWidget {
  const FamilyDecisionScreen({super.key});

  @override
  ConsumerState<FamilyDecisionScreen> createState() =>
      _FamilyDecisionScreenState();
}

class _FamilyDecisionScreenState extends ConsumerState<FamilyDecisionScreen> {
  bool _isCreating = false;
  bool _isJoining = false;
  bool _showCodeInput = false;
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _createFamily() async {
    setState(() => _isCreating = true);
    final result = await ref.read(familyActionsProvider).createFamily();
    if (!mounted) return;
    setState(() => _isCreating = false);

    if (result.isSuccess) {
      // Manuel navigator yok. main.dart'ın reaktif beynini tetikle:
      // family_id artık dolu → hasFamilyProvider true döner →
      // hasAnyChild false → OnboardingScreen otomatik açılır.
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) ref.invalidate(hasFamilyProvider(userId));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage ?? 'Aile oluşturulamadı')),
      );
    }
  }

  Future<void> _joinFamily() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Davet kodu 6 haneli olmalıdır')),
      );
      return;
    }

    setState(() => _isJoining = true);
    final result = await ref.read(familyActionsProvider).joinFamily(code);
    if (!mounted) return;
    setState(() => _isJoining = false);

    if (result.isSuccess) {
      // Aynı reaktif tetikleme: hasFamilyProvider invalidate → main.dart router devralır.
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) ref.invalidate(hasFamilyProvider(userId));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(result.errorMessage ?? 'Koda katılım başarısız')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.family_restroom_rounded,
                  size: 80, color: AppColors.primary),
              const SizedBox(height: 24),
              Text(
                'Hoş Geldiniz!',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Uygulamayı kullanmaya başlamak için kendi ailenizi kurabilir veya eşinizin gönderdiği davet koduyla mevcut bir aileye katılabilirsiniz.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: (_isCreating || _isJoining) ? null : _createFamily,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isCreating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Kendi Ailemi Kur',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              AnimatedCrossFade(
                firstChild: OutlinedButton(
                  onPressed: (_isCreating || _isJoining)
                      ? null
                      : () => setState(() => _showCodeInput = true),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: AppColors.primary),
                  ),
                  child: const Text('Davet Kodum Var',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                ),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _codeController,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          letterSpacing: 8,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: 'KODU GİRİN',
                        counterText: '',
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _isJoining ? null : _joinFamily,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isJoining
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Aileye Katıl',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _showCodeInput = false),
                      child: const Text('Vazgeç',
                          style: TextStyle(color: Colors.grey)),
                    )
                  ],
                ),
                crossFadeState: _showCodeInput
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
