import 'dart:js_interop';

import 'package:web/web.dart' as web;

web.EventListener? _listener;

void registerAppReflowSignal(void Function() onSignal) {
  unregisterAppReflowSignal();
  _listener = ((web.Event _) {
    onSignal();
  }).toJS;

  web.window.addEventListener('resize', _listener);
  web.window.addEventListener('orientationchange', _listener);
  web.window.addEventListener('pageshow', _listener);
  web.document.addEventListener('visibilitychange', _listener);
}

void unregisterAppReflowSignal() {
  if (_listener == null) {
    return;
  }
  web.window.removeEventListener('resize', _listener);
  web.window.removeEventListener('orientationchange', _listener);
  web.window.removeEventListener('pageshow', _listener);
  web.document.removeEventListener('visibilitychange', _listener);
  _listener = null;
}
