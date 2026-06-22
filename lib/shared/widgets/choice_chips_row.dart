import 'package:flutter/material.dart';

import '../../app/app_palette.dart';

class ChoiceChipsRow<T> extends StatelessWidget {
  const ChoiceChipsRow({
    required this.value,
    required this.options,
    required this.labelBuilder,
    required this.onChanged,
    super.key,
  });

  final T value;
  final List<T> options;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          options.map((option) {
            final selected = option == value;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow:
                    selected
                        ? [
                          BoxShadow(
                            color: palette.primary.withValues(alpha: 0.16),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ]
                        : null,
              ),
              child: ChoiceChip(
                label: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(labelBuilder(option)),
                ),
                selected: selected,
                onSelected: (_) => onChanged(option),
              ),
            );
          }).toList(),
    );
  }
}
