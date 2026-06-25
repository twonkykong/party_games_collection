import 'package:flutter/material.dart';

import '../../app/app_palette.dart';

class AppShell extends StatefulWidget {
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
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    _triggerReflow();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _triggerReflow();
    }
  }

  void _triggerReflow() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final mediaQuery = MediaQuery.of(context);
    final topInset = mediaQuery.padding.top;
    final bottomInset = mediaQuery.padding.bottom;
    final hasHeader = widget.title != null;

    return Scaffold(
      backgroundColor: palette.backgroundTop,
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
              child: IgnorePointer(
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
            ),
            Positioned(
              top: 120,
              left: -60,
              child: IgnorePointer(
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
            ),
            Column(
              children: [
                Container(height: topInset, color: palette.backgroundTop),
                if (hasHeader)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: SizedBox(
                        height: 52,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 48,
                              child:
                                  widget.leading ??
                                  IconButton(
                                    onPressed: () {
                                      Navigator.maybePop(context);
                                    },
                                    tooltip: null,
                                    color: palette.textPrimary,
                                    icon: const BackButtonIcon(),
                                  ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.title!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    Theme.of(
                                      context,
                                    ).appBarTheme.titleTextStyle,
                              ),
                            ),
                            if (widget.actions != null) ...widget.actions!,
                          ],
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: SafeArea(
                    top: false,
                    left: true,
                    right: true,
                    bottom: true,
                    minimum: EdgeInsets.only(bottom: bottomInset > 0 ? 0 : 8),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
