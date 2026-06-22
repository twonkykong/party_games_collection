import 'package:flutter/material.dart';

import '../../app/app_palette.dart';
import 'section_card.dart';

class RevealCard extends StatelessWidget {
  const RevealCard({
    required this.revealed,
    required this.hiddenLabel,
    required this.revealedChild,
    required this.onTap,
    super.key,
    this.helperText,
  });

  final bool revealed;
  final String hiddenLabel;
  final Widget revealedChild;
  final String? helperText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: SectionCard(
          key: ValueKey(revealed),
          color: revealed ? palette.surface : palette.surfaceMuted,
          padding: const EdgeInsets.all(28),
          child: SizedBox(
            width: double.infinity,
            height: 320,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (revealed)
                  revealedChild
                else ...[
                  Icon(
                    Icons.visibility_off_rounded,
                    size: 34,
                    color: palette.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    hiddenLabel,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontSize: 22),
                  ),
                ],
                if (helperText != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    helperText!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
