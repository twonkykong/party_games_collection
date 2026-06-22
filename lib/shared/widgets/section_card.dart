import 'package:flutter/material.dart';

import '../../app/app_palette.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(20),
    this.color,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? palette.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: palette.outline),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: palette.white.withValues(alpha: 0.06),
            blurRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
