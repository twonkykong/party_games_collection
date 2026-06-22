import 'package:flutter/material.dart';

import '../../app/app_palette.dart';

class WheelIndexPicker extends StatefulWidget {
  const WheelIndexPicker({
    required this.itemCount,
    required this.value,
    required this.onChanged,
    super.key,
    this.onValueSettled,
    this.labelBuilder,
  });

  final int itemCount;
  final int value;
  final ValueChanged<int> onChanged;
  final ValueChanged<int>? onValueSettled;
  final String Function(int value)? labelBuilder;

  @override
  State<WheelIndexPicker> createState() => _WheelIndexPickerState();
}

class _WheelIndexPickerState extends State<WheelIndexPicker> {
  late PageController _controller;
  bool _isDragging = false;

  int get _effectiveValue {
    if (widget.itemCount <= 0) {
      return 1;
    }
    return widget.value.clamp(1, widget.itemCount);
  }

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      viewportFraction: 0.42,
      initialPage: _effectiveValue - 1,
    );
  }

  @override
  void didUpdateWidget(covariant WheelIndexPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemCount != widget.itemCount ||
        oldWidget.value != widget.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller.hasClients && !_isDragging) {
          final targetPage = _effectiveValue - 1;
          final currentPage =
              _controller.page ?? _controller.initialPage.toDouble();
          if ((currentPage - targetPage).abs() < 0.01) {
            return;
          }
          _controller.animateToPage(
            targetPage,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);

    return Container(
      height: 132,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.outline),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              height: 82,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: palette.primarySoft,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                _isDragging = true;
              } else if (notification is ScrollEndNotification) {
                _isDragging = false;
              }
              return false;
            },
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.itemCount,
              padEnds: true,
              onPageChanged: (index) {
                final value = index + 1;
                widget.onChanged(value);
                widget.onValueSettled?.call(value);
              },
              itemBuilder: (context, index) {
                final value = index + 1;
                final selected = widget.value == value;
                final label = widget.labelBuilder?.call(value) ?? 'Игрок';
                return Center(
                  child: AnimatedScale(
                    scale: selected ? 1.0 : 0.93,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    child: AnimatedOpacity(
                      opacity: selected ? 1 : 0.72,
                      duration: const Duration(milliseconds: 180),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        width: 118,
                        height: 72,
                        decoration: BoxDecoration(
                          color: selected ? palette.primary : palette.surface,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow:
                              selected
                                  ? [
                                    BoxShadow(
                                      color: palette.primary.withValues(
                                        alpha: 0.18,
                                      ),
                                      blurRadius: 18,
                                      offset: const Offset(0, 10),
                                    ),
                                  ]
                                  : null,
                          border: Border.all(
                            color:
                                selected
                                    ? Colors.transparent
                                    : palette.outline.withValues(alpha: 0.7),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$value',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontSize: 24,
                                color:
                                    selected
                                        ? palette.white
                                        : palette.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              label,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color:
                                    selected
                                        ? palette.white.withValues(alpha: 0.86)
                                        : palette.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
