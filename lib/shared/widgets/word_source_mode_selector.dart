import 'package:flutter/material.dart';

import '../../app/app_palette.dart';
import '../../core/models/word_source_mode.dart';

class WordSourceModeSelector extends StatelessWidget {
  const WordSourceModeSelector({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final WordSourceMode value;
  final ValueChanged<WordSourceMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: WordSourceMode.values
              .map(
                (item) => Padding(
                  padding: EdgeInsets.only(
                    right: item == WordSourceMode.values.last ? 0 : 8,
                  ),
                  child: _SourceModeChip(
                    label: item.label,
                    selected: item == value,
                    onTap: () => onChanged(item),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _SourceModeChip extends StatelessWidget {
  const _SourceModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Material(
      color: selected ? palette.primarySoft : palette.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color:
                  selected
                      ? palette.primary.withValues(alpha: 0.22)
                      : palette.outline,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: palette.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
