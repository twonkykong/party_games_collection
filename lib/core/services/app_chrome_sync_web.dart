import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

String _toHexColor(Color color) {
  return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
}

web.HTMLMetaElement? _findMeta(String name) {
  return web.document.querySelector('meta[name="$name"]') as web.HTMLMetaElement?;
}

Future<void> syncWebAppChrome({
  required Brightness brightness,
  required Color backgroundColor,
}) async {
  final themeMeta = _findMeta('theme-color');
  if (themeMeta != null) {
    themeMeta.content = _toHexColor(backgroundColor);
  }

  final statusBarMeta = _findMeta('apple-mobile-web-app-status-bar-style');
  if (statusBarMeta != null) {
    statusBarMeta.content =
        brightness == Brightness.dark ? 'black-translucent' : 'default';
  }

  final hex = _toHexColor(backgroundColor);
  web.document.documentElement?.setAttribute('style', 'background-color: $hex;');
  web.document.body?.setAttribute('style', 'background-color: $hex;');
}
