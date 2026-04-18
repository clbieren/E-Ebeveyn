import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_colors.dart';

/// BottomSheet içinde gösterilen tek bir seçenek satırı.
///
/// Tasarım: Büyük dokunma alanı (64dp), sola hizalı içerik,
/// seçim anında kapanma (hız esastır).
class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.emoji,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
    this.isLast = false,
  });

  final String emoji;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      splashColor: color.withAlpha(31), // 0.12 * 255
      highlightColor: color.withAlpha(20), // 0.08 * 255
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          14,
          20,
          isLast ? 14 : 14,
        ),
        child: Row(
          children: [
            // İkon kutusu
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withAlpha(31), // 0.12 * 255
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 14),

            // Etiket + açıklama
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Ok
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color.withAlpha(153), // 0.6 * 255
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

/// Başlık şeridi — sheet handle dahil.
class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.emoji, required this.title});

  final String emoji;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(null),
            child: const Icon(
              Icons.close_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PUBLIC API — Gösterme fonksiyonları
// =============================================================================

/// Beslenme türü seçim sheet'ini gösterir.
///
/// Returns: seçilen subType string'i ('breast_milk' | 'formula')
///          veya kullanıcı kapattıysa null.
Future<String?> showFeedSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.surfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const _SheetHeader(emoji: '🍼', title: 'Beslenme Türü'),

          const Divider(height: 1),

          _OptionTile(
            emoji: '🤱',
            label: 'Anne Sütü',
            description: 'Doğrudan emzirme veya sütüt',
            color: AppColors.secondary,
            onTap: () async {
              HapticFeedback.lightImpact();
              Navigator.of(ctx).pop('breast_milk');
            },
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1),
          ),

          _OptionTile(
            emoji: '🥛',
            label: 'Mama',
            description: 'Hazır mama veya ek gıda',
            color: AppColors.secondary,
            isLast: true,
            onTap: () async {
              HapticFeedback.lightImpact();
              Navigator.of(ctx).pop('formula');
            },
          ),

          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// Bez türü seçim sheet'ini gösterir.
///
/// Returns: seçilen subType string'i ('dirty' | 'wet' | 'clean')
///          veya kullanıcı kapattıysa null.
Future<String?> showDiaperSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.surfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const _SheetHeader(emoji: '🧻', title: 'Bez Türü'),
          const Divider(height: 1),
          _OptionTile(
            emoji: '💛',
            label: 'Islak',
            description: 'Sadece ıslak bez',
            color: AppColors.tertiary,
            onTap: () async {
              HapticFeedback.lightImpact();
              Navigator.of(ctx).pop('wet');
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1),
          ),
          _OptionTile(
            emoji: '💩',
            label: 'Kirli',
            description: 'Gaita içeren bez',
            color: AppColors.tertiary,
            onTap: () async {
              HapticFeedback.lightImpact();
              Navigator.of(ctx).pop('dirty');
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1),
          ),
          _OptionTile(
            emoji: '✨',
            label: 'Temiz (Önleyici)',
            description: 'Islak olmayan rutin değişim',
            color: AppColors.tertiary,
            isLast: true,
            onTap: () async {
              HapticFeedback.lightImpact();
              Navigator.of(ctx).pop('clean');
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
