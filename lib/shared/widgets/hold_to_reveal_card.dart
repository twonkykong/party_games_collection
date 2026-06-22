import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app_palette.dart';
import 'section_card.dart';

class HoldToRevealCard extends StatefulWidget {
  const HoldToRevealCard({
    required this.revealed,
    required this.onReveal,
    required this.onHide,
    required this.child,
    super.key,
  });

  final bool revealed;
  final VoidCallback onReveal;
  final VoidCallback onHide;
  final Widget child;

  @override
  State<HoldToRevealCard> createState() => _HoldToRevealCardState();
}

class _HoldToRevealCardState extends State<HoldToRevealCard> {
  static const _holdDuration = Duration(milliseconds: 800);
  Timer? _timer;
  double _progress = 0;
  bool _revealedByHold = false;

  void _startHold() {
    if (widget.revealed) {
      return;
    }
    _timer?.cancel();
    const stepMs = 16;
    var elapsed = 0;
    _timer = Timer.periodic(const Duration(milliseconds: stepMs), (timer) {
      elapsed += stepMs;
      setState(() {
        _progress = (elapsed / _holdDuration.inMilliseconds).clamp(0, 1);
      });
      if (_progress >= 1) {
        timer.cancel();
        _revealedByHold = true;
        widget.onReveal();
      }
    });
  }

  void _endHold() {
    _timer?.cancel();
    if (!widget.revealed) {
      setState(() {
        _progress = 0;
      });
    }
  }

  @override
  void didUpdateWidget(covariant HoldToRevealCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.revealed && !widget.revealed) {
      _progress = 0;
      _revealedByHold = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return GestureDetector(
      onTapDown: (_) => _startHold(),
      onTapUp: (_) => _endHold(),
      onTapCancel: _endHold,
      onTap:
          widget.revealed
              ? () {
                if (_revealedByHold) {
                  _revealedByHold = false;
                  return;
                }
                widget.onHide();
              }
              : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final tilt = Tween(begin: 0.08, end: 0.0).animate(animation);
              return AnimatedBuilder(
                animation: animation,
                child: child,
                builder: (context, builtChild) {
                  return Transform(
                    alignment: Alignment.center,
                    transform:
                        Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(tilt.value),
                    child: FadeTransition(
                      opacity: animation,
                      child: builtChild,
                    ),
                  );
                },
              );
            },
            child: SectionCard(
              key: ValueKey(widget.revealed),
              color: widget.revealed ? palette.surface : palette.surfaceMuted,
              padding: const EdgeInsets.all(28),
              child: SizedBox(
                width: double.infinity,
                height: 340,
                child:
                    widget.revealed
                        ? widget.child
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                color: palette.primarySoft,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Icon(
                                Icons.front_hand_rounded,
                                size: 34,
                                color: palette.primary,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Удерживайте карточку, чтобы открыть слово',
                              textAlign: TextAlign.center,
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(fontSize: 18),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'После открытия обычный тап снова скроет слово.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
              ),
            ),
          ),
          if (!widget.revealed)
            Positioned(
              left: 28,
              right: 28,
              bottom: 28,
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: _progress,
                    minHeight: 12,
                    backgroundColor: palette.surfaceStrong,
                    borderRadius: BorderRadius.circular(999),
                    valueColor: AlwaysStoppedAnimation(palette.primary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _progress > 0
                        ? 'Продолжайте удерживать'
                        : 'Зажмите на 800 мс',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
