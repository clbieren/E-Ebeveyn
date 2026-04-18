import 'package:flutter/material.dart';

class CategoryHeader extends StatelessWidget {
  const CategoryHeader({
    required this.title,
    super.key,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: cs.onSurface,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
