import 'package:flutter/material.dart';

import '../../app/app_palette.dart';
import '../../core/models/dictionary_mode.dart';

class DictionaryModeSlider extends StatelessWidget {
  const DictionaryModeSlider({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final DictionaryMode value;
  final ValueChanged<DictionaryMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    const options = DictionaryMode.values;
    final selectedIndex = options.indexOf(value);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final segmentWidth = width / options.length;

        int resolveIndex(double dx) {
          if (width <= 0) {
            return selectedIndex;
          }
          return (dx.clamp(0.0, width - 1) / segmentWidth).floor().clamp(
            0,
            options.length - 1,
          );
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp:
              (details) =>
                  onChanged(options[resolveIndex(details.localPosition.dx)]),
          onHorizontalDragUpdate: (details) {
            final next = options[resolveIndex(details.localPosition.dx)];
            if (next != value) {
              onChanged(next);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  for (final option in options)
                    Expanded(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color:
                              option == value
                                  ? palette.textPrimary
                                  : palette.textSecondary,
                          fontWeight:
                              option == value
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                        ),
                        child: Text(option.label, textAlign: TextAlign.center),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 34,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 10,
                      right: 10,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: palette.surfaceMuted,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: palette.outline),
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      left:
                          (segmentWidth * selectedIndex) +
                          (segmentWidth / 2) -
                          15,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: palette.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: palette.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: palette.primary.withValues(alpha: 0.22),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                switch (value) {
                  DictionaryMode.family =>
                    'Только обычные слова без грубых вариантов.',
                  DictionaryMode.mixed =>
                    'Смешанная подборка: и обычные, и более смелые слова.',
                  DictionaryMode.dirty => 'Только взрослые и грубые слова.',
                },
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: palette.textSecondary),
              ),
            ],
          ),
        );
      },
    );
  }
}
