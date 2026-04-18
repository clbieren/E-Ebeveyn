import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

class AnalyzeButtonWidget extends StatelessWidget {
  const AnalyzeButtonWidget({
    required this.isLoading,
    required this.onPressed,
    super.key,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.psychology_alt_rounded),
        label: Text(isLoading ? 'Analiz ediliyor...' : 'AI Analizi Baslat'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          textStyle: const TextStyle(inherit: true).merge(
            GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
