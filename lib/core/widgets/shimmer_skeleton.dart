import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Şık iskelet yükleme kutusu.
///
/// `CircularProgressIndicator` yerine, UI akışını daha stabil ve modern tutar.
class ShimmerSkeleton extends StatelessWidget {
  const ShimmerSkeleton({
    super.key,
    required this.height,
    this.width = double.infinity,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  final double height;
  final double width;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final base = cs.surfaceContainerHighest;
    final highlight = cs.surfaceContainerHighest.withAlpha(153); // 0.6 * 255

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}
