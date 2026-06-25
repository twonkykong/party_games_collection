import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

String _toHexColor(Color color) {
  return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
}

web.HTMLMetaElement? _findMeta(String name) {
  return web.document.querySelector('meta[name="$name"]')
      as web.HTMLMetaElement?;
}

Future<void> syncWebAppChrome({
  required Brightness brightness,
  required Color backgroundColor,
}) async {
  final hex = _toHexColor(backgroundColor);

  final themeMeta = _findMeta('theme-color');
  if (themeMeta != null) {
    themeMeta.content = hex;
  }

  final root = web.document.documentElement as web.HTMLElement?;
  root?.style.backgroundColor = hex;
  web.document.body?.style.backgroundColor = hex;

  final statusBarCover =
      web.document.querySelector('#app-status-bar-cover') as web.HTMLElement?;
  statusBarCover?.style.backgroundColor = hex;

  root?.style.setProperty(
    'color-scheme',
    brightness == Brightness.dark ? 'dark' : 'light',
  );
  web.document.body?.style.setProperty(
    'color-scheme',
    brightness == Brightness.dark ? 'dark' : 'light',
  );
}
