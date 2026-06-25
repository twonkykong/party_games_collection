import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_chrome_sync_stub.dart'
    if (dart.library.html) 'app_chrome_sync_web.dart'
    as app_chrome_sync_platform;

class AppChromeSync extends StatefulWidget {
  const AppChromeSync({
    required this.brightness,
    required this.chromeColor,
    required this.child,
    super.key,
  });

  final Brightness brightness;
  final Color chromeColor;
  final Widget child;

  @override
  State<AppChromeSync> createState() => _AppChromeSyncState();
}

class _AppChromeSyncState extends State<AppChromeSync>
    with WidgetsBindingObserver {
  Brightness? _lastBrightness;
  Color? _lastChromeColor;
  final List<Timer> _syncTimers = <Timer>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleSync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleSync();
  }

  @override
  void didUpdateWidget(covariant AppChromeSync oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.brightness != widget.brightness ||
        oldWidget.chromeColor != widget.chromeColor) {
      _scheduleSync();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scheduleSync(force: true);
    }
  }

  @override
  void didChangePlatformBrightness() {
    _scheduleSync(force: true);
  }

  @override
  void didChangeMetrics() {
    _scheduleSync(force: true);
  }

  void _scheduleSync({bool force = false}) {
    if (!force &&
        _lastBrightness == widget.brightness &&
        _lastChromeColor == widget.chromeColor) {
      return;
    }
    _lastBrightness = widget.brightness;
    _lastChromeColor = widget.chromeColor;
    for (final timer in _syncTimers) {
      timer.cancel();
    }
    _syncTimers.clear();

    Future<void> runSync() async {
      if (!mounted) {
        return;
      }
      final overlayStyle =
          widget.brightness == Brightness.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark;
      SystemChrome.setSystemUIOverlayStyle(
        overlayStyle.copyWith(statusBarColor: Colors.transparent),
      );
      await app_chrome_sync_platform.syncWebAppChrome(
        brightness: widget.brightness,
        backgroundColor: widget.chromeColor,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(runSync());
    });

    for (final delay in const [90, 240]) {
      _syncTimers.add(
        Timer(Duration(milliseconds: delay), () {
          unawaited(runSync());
        }),
      );
    }
  }

  @override
  void dispose() {
    for (final timer in _syncTimers) {
      timer.cancel();
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overlayStyle =
        widget.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle.copyWith(statusBarColor: Colors.transparent),
      child: widget.child,
    );
  }
}
