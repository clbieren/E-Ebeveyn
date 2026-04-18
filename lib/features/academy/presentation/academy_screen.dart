import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:babytracker/core/widgets/shimmer_skeleton.dart';
import 'package:babytracker/features/academy/providers/academy_providers.dart';
import 'package:babytracker/features/academy/presentation/pdf_viewer_screen.dart';

/// Akademi ekranı — Supabase'e hazır FutureProvider tabanlı.
class AcademyScreen extends ConsumerWidget {
  const AcademyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final guidesAsync = ref.watch(academyProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: const Text('Akademi'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Text(
              'Güvenilir ebeveynlik rehberleri',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
          ),
        ),
      ),
      body: guidesAsync.when(
        loading: () => const _AcademySkeletonList(),
        error: (_, __) => _AcademyError(cs: cs),
        data: (items) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) => _GuideCard(
            item: items[i],
            isDark: isDark,
            cs: cs,
          ),
        ),
      ),
    );
  }
}

// ── Kart ─────────────────────────────────────────────────────────────────────

class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.item,
    required this.isDark,
    required this.cs,
  });

  final AcademyGuide item;
  final bool isDark;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final iconColor = cs.primary;

    return Card(
      color: cs.surfaceContainerHighest,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _onTap(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // İkon kutusu
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(31),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(Icons.picture_as_pdf_rounded,
                    color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),

              // Metin grubu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık + tag aynı satırda (Flexible ile taşmaz)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: Theme.of(context).textTheme.titleSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _Tag(label: 'PDF', color: cs.primary),
                      ],
                    ),
                    if (item.description != null &&
                        item.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Ok ikonu
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(guide: item),
      ),
    );
  }
}

// ── Tag ───────────────────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(31), // 0.12 * 255
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(77)), // 0.3 * 255
      ),
      child: Text(
        label,
        style: TextStyle(
          inherit: true,
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AcademySkeletonList extends StatelessWidget {
  const _AcademySkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => const _AcademySkeletonCard(),
    );
  }
}

class _AcademySkeletonCard extends StatelessWidget {
  const _AcademySkeletonCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            ShimmerSkeleton(
              height: 48,
              width: 48,
              borderRadius: BorderRadius.all(Radius.circular(13)),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerSkeleton(height: 14, width: 180),
                  SizedBox(height: 10),
                  ShimmerSkeleton(height: 12, width: 240),
                  SizedBox(height: 6),
                  ShimmerSkeleton(height: 12, width: 200),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AcademyError extends StatelessWidget {
  const _AcademyError({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, color: cs.onSurfaceVariant, size: 34),
            const SizedBox(height: 10),
            Text(
              'Akademi içerikleri yüklenemedi.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Lütfen internet bağlantınızı kontrol edip tekrar deneyin.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
