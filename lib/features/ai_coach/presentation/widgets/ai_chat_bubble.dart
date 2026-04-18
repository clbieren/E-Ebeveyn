import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../../core/theme/app_colors.dart';

class AiChatBubble extends StatelessWidget {
  const AiChatBubble({
    required this.markdownText,
    super.key,
  });

  final String markdownText;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: MarkdownBody(
        data: markdownText,
        styleSheet: MarkdownStyleSheet(
          p: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          h1: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          h2: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          listBullet: const TextStyle(color: AppColors.primary),
        ),
      ),
    );
  }
}
