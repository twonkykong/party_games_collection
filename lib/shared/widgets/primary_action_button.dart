import 'package:flutter/material.dart';

import '../../app/app_palette.dart';

class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final enabled = onPressed != null;
    final buttonChild =
        icon == null
            ? Text(label)
            : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 10),
                Text(label),
              ],
            );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            enabled ? palette.primary : palette.surfaceStrong,
            enabled ? palette.primaryStrong : palette.surfaceMuted,
          ],
        ),
        boxShadow:
            enabled
                ? [
                  BoxShadow(
                    color: palette.primary.withValues(alpha: 0.24),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ]
                : null,
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: enabled ? palette.white : palette.textSecondary,
        ),
        child: buttonChild,
      ),
    );
  }
}
