import 'package:flutter/material.dart';

import '../../app/app_palette.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    required this.child,
    super.key,
    this.title,
    this.actions,
    this.leading,
  });

  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Scaffold(
      appBar:
          title == null
              ? null
              : AppBar(
                title: Text(title!),
                centerTitle: false,
                leading: leading,
                actions: actions,
              ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [palette.backgroundTop, palette.backgroundBottom],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      palette.backgroundOrbPrimary,
                      palette.backgroundOrbPrimary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 120,
              left: -60,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      palette.backgroundOrbSecondary,
                      palette.backgroundOrbSecondary.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
