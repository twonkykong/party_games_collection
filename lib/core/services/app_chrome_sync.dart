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

class _AppChromeSyncState extends State<AppChromeSync> {
  Brightness? _lastBrightness;
  Color? _lastChromeColor;

  @override
  void initState() {
    super.initState();
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

  void _scheduleSync() {
    if (_lastBrightness == widget.brightness &&
        _lastChromeColor == widget.chromeColor) {
      return;
    }
    _lastBrightness = widget.brightness;
    _lastChromeColor = widget.chromeColor;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
