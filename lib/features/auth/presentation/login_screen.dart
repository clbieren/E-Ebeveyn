import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/auth/domain/auth_failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../presentation/controllers/login_controller.dart';
import '../../onboarding/presentation/family_decision_screen.dart'; // YENİ EKLENDİ
import '../../main/presentation/main_layout.dart'; // YENİ EKLENDİ

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isSignUpMode = useState(false);
    final isPasswordVisible = useState(false);
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final wasLoading = useState(false);

    final controllerState = ref.watch(loginControllerProvider);
    final isLoading = controllerState.isLoading;

    useEffect(() {
      if (!isLoading && wasLoading.value) {
        if (!controllerState.hasError && isSignUpMode.value) {
          _showSuccessSnackBar(
            context,
            'Hesabınız başarıyla oluşturuldu! Lütfen e-postanızı kontrol edin.',
          );
          ref.read(loginControllerProvider.notifier).resetState();
          isSignUpMode.value = false;
          emailController.clear();
          passwordController.clear();
        }
      }
      wasLoading.value = isLoading;
      return null;
    }, [isLoading]);

    ref.listen<AsyncValue<void>>(loginControllerProvider, (_, next) {
      next.whenOrNull(
        error: (error, _) {
          final message = error is InvalidCredentials
              ? 'E-posta veya şifre hatalı'
              : (next.errorMessage ?? 'Bir hata oluştu');
          _showErrorSnackBar(context, message);
          ref.read(loginControllerProvider.notifier).resetState();
        },
      );
    });

    // ── YENİLENEN AKILLI YÖNLENDİRME (SUBMIT) ─────────────────────────────────
    Future<void> onSubmit() async {
      if (!formKey.currentState!.validate()) return;
      FocusScope.of(context).unfocus();

      final notifier = ref.read(loginControllerProvider.notifier);
      final email = emailController.text;
      final password = passwordController.text;

      bool? hasFamily;

      if (isSignUpMode.value) {
        hasFamily = await notifier.signUp(email: email, password: password);
      } else {
        hasFamily = await notifier.signIn(email: email, password: password);
      }

      // Eğer hasFamily null döndüyse, bir hata oluşmuştur. İleri gitmiyoruz.
      // Ekranda `listen` bloğu hatayı algılayıp alttan snackbar çıkaracak zaten.
      if (hasFamily == null) return;
      if (!context.mounted) return;

      if (hasFamily) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainLayout()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const FamilyDecisionScreen()),
          (route) => false,
        );
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),
                  _AppLogo(),
                  const SizedBox(height: 40),
                  _Header(isSignUpMode: isSignUpMode.value),
                  const SizedBox(height: 36),
                  _EmailField(
                    controller: emailController,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 14),
                  _PasswordField(
                    controller: passwordController,
                    enabled: !isLoading,
                    isVisible: isPasswordVisible.value,
                    onToggleVisibility: () =>
                        isPasswordVisible.value = !isPasswordVisible.value,
                  ),
                  const SizedBox(height: 28),
                  _SubmitButton(
                    isLoading: isLoading,
                    isSignUpMode: isSignUpMode.value,
                    onPressed: onSubmit, // Yenilenen metot buraya bağlandı
                  ),
                  const SizedBox(height: 24),
                  _ModeSwitcher(
                    isSignUpMode: isSignUpMode.value,
                    onToggle: () {
                      isSignUpMode.value = !isSignUpMode.value;
                      emailController.clear();
                      passwordController.clear();
                    },
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.error, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 13, height: 1.4),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.surfaceContainer,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.error, width: 0.5),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          duration: const Duration(seconds: 4),
        ),
      );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 13, height: 1.4),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.surfaceContainer,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.primary, width: 0.5),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          duration: const Duration(seconds: 4),
        ),
      );
  }
}

class _AppLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Icon(
          Icons.baby_changing_station_rounded,
          size: 36,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isSignUpMode});
  final bool isSignUpMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            isSignUpMode ? 'Hesap Oluştur' : 'Hoş Geldiniz',
            key: ValueKey(isSignUpMode),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isSignUpMode
              ? 'Bebeğinizi takip etmeye hemen başlayın.'
              : 'Bebeğinizin günlüğüne devam edin.',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller, required this.enabled});

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      decoration: const InputDecoration(
        labelText: 'E-posta',
        hintText: 'ornek@mail.com',
        prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'E-posta adresi gerekli.';
        }
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
          return 'Geçerli bir e-posta adresi girin.';
        }
        return null;
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.enabled,
    required this.isVisible,
    required this.onToggleVisibility,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool isVisible;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: !isVisible,
      textInputAction: TextInputAction.done,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        labelText: 'Şifre',
        hintText: '••••••••',
        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
        suffixIcon: IconButton(
          onPressed: onToggleVisibility,
          icon: Icon(
            isVisible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Şifre gerekli.';
        }
        if (value.length < 8) {
          return 'Şifre en az 8 karakter olmalı.';
        }
        return null;
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.isLoading,
    required this.isSignUpMode,
    required this.onPressed,
  });

  final bool isLoading;
  final bool isSignUpMode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primaryDim,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(AppColors.onPrimary),
                ),
              )
            : Text(
                isSignUpMode ? 'Hesap Oluştur' : 'Giriş Yap',
                style: const TextStyle(
                  color: AppColors.onPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
      ),
    );
  }
}

class _ModeSwitcher extends StatelessWidget {
  const _ModeSwitcher({
    required this.isSignUpMode,
    required this.onToggle,
  });

  final bool isSignUpMode;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isSignUpMode ? 'Zaten hesabın var mı?' : 'Hesabın yok mu?',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        TextButton(
          onPressed: onToggle,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            isSignUpMode ? 'Giriş Yap' : 'Kayıt Ol',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
