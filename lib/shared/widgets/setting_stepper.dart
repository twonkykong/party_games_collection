import 'package:flutter/material.dart';

import '../../app/app_palette.dart';

class SettingStepper extends StatelessWidget {
  const SettingStepper({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    super.key,
    this.valueLabelBuilder,
    this.onDecrease,
    this.onIncrease,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final String Function(int value)? valueLabelBuilder;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final valueLabel = valueLabelBuilder?.call(value) ?? '$value';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: palette.surfaceMuted,
            borderRadius: BorderRadius.circular(22),
          ),
          child:
              isCompact
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _StepperButton(
                            icon: Icons.remove_rounded,
                            onPressed:
                                value > min
                                    ? (onDecrease ?? () => onChanged(value - 1))
                                    : null,
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                valueLabel,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.copyWith(fontSize: 22),
                              ),
                            ),
                          ),
                          _StepperButton(
                            icon: Icons.add_rounded,
                            onPressed:
                                value < max
                                    ? (onIncrease ?? () => onChanged(value + 1))
                                    : null,
                            filled: true,
                          ),
                        ],
                      ),
                    ],
                  )
                  : Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      _StepperButton(
                        icon: Icons.remove_rounded,
                        onPressed:
                            value > min
                                ? (onDecrease ?? () => onChanged(value - 1))
                                : null,
                      ),
                      SizedBox(
                        width: 64,
                        child: Center(
                          child: Text(
                            valueLabel,
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(fontSize: 22),
                          ),
                        ),
                      ),
                      _StepperButton(
                        icon: Icons.add_rounded,
                        onPressed:
                            value < max
                                ? (onIncrease ?? () => onChanged(value + 1))
                                : null,
                        filled: true,
                      ),
                    ],
                  ),
        );
      },
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onPressed,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return SizedBox(
      width: 48,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: filled ? palette.primary : palette.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: palette.outline),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          icon: Icon(icon),
          color: filled ? palette.white : palette.textPrimary,
        ),
      ),
    );
  }
}
